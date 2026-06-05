import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/player_service.dart';
import 'services/podcast_service.dart';
import 'services/listening_history.dart';
import 'services/clip_service.dart';
import 'widgets/player/mini_player_bar.dart';
import 'widgets/player/full_player_sheet.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/search_screen.dart';
import 'screens/timeline_screen.dart';

void main() {
  runApp(const WavelineApp());
}

class WavelineApp extends StatelessWidget {
  const WavelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClipService()..load()),
        ChangeNotifierProvider(create: (_) => ListeningHistory()..load()),
        ChangeNotifierProxyProvider<ListeningHistory, PlayerService>(
          create: (_) => PlayerService(),
          update: (_, history, player) => player!..history = history,
        ),
        Provider(create: (_) => PodcastService(), dispose: (_, s) => s.dispose()),
      ],
      child: MaterialApp(
        title: 'Waveline',
        theme: WavelineTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _playerAnimController;
  late Animation<Offset> _playerSlide;
  bool _playerExpanded = false;

  final _screens = const [
    HomeScreen(),
    LibraryScreen(),
    SearchScreen(),
    TimelineScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _playerAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _playerSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _playerAnimController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _playerAnimController.dispose();
    super.dispose();
  }

  void _togglePlayer() {
    if (!context.read<PlayerService>().hasContent) return;
    setState(() => _playerExpanded = !_playerExpanded);
    if (_playerExpanded) {
      _playerAnimController.forward();
    } else {
      _playerAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 72.0;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
              if (player.hasContent)
                GestureDetector(
                  onTap: _togglePlayer,
                  child: const MiniPlayerBar(),
                ),
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (i) {
                    if (_playerExpanded) _togglePlayer();
                    setState(() => _currentIndex = i);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.library_music_outlined),
                      selectedIcon: Icon(Icons.library_music),
                      label: 'Library',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search_outlined),
                      selectedIcon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: 'History',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (player.hasContent)
            AnimatedBuilder(
              animation: _playerSlide,
              builder: (context, child) {
                final offset = _playerSlide.value;
                final playerHeight = MediaQuery.of(context).size.height -
                    navBarHeight -
                    bottomInset;
                return Transform.translate(
                  offset: Offset(0, playerHeight * offset.dy),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      final delta = details.primaryDelta ?? 0;
                      _playerAnimController.value -= delta / playerHeight;
                    },
                    onVerticalDragEnd: (details) {
                      if (_playerAnimController.value > 0.5) {
                        _playerAnimController.forward();
                        setState(() => _playerExpanded = true);
                      } else {
                        _playerAnimController.reverse();
                        setState(() => _playerExpanded = false);
                      }
                    },
                    child: Container(
                      height: playerHeight,
                      alignment: Alignment.bottomCenter,
                      child: FullPlayerSheet(
                        onCollapse: () {
                          if (_playerExpanded) _togglePlayer();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
