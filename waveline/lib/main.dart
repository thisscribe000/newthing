import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/player_service.dart';
import 'services/podcast_service.dart';
import 'services/listening_history.dart';
import 'services/clip_service.dart';
import 'services/favorite_service.dart';
import 'services/feed_service.dart';
import 'widgets/player/mini_player_bar.dart';
import 'widgets/player/full_player_sheet.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/search_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/feed_screen.dart';

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
        ChangeNotifierProvider(create: (_) => FavoriteService()..load()),
        ChangeNotifierProvider(create: (_) => FeedService()..load()),
        ChangeNotifierProvider(create: (_) => ListeningHistory()..load()),
        ChangeNotifierProxyProvider<ListeningHistory, PlayerService>(
          create: (_) => PlayerService(),
          update: (_, history, player) => player!..history = history,
        ),
        Provider(
          create: (_) => PodcastService(),
          dispose: (_, s) => s.dispose(),
        ),
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

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _playerAnimController;
  late Animation<double> _playerExpand;
  double _playerExpandValue = 0.0; // 0 = minimized, 1 = fullscreen
  bool _isFullscreen = false;

  final _screens = const [
    HomeScreen(),
    FeedScreen(),
    LibraryScreen(),
    SearchScreen(),
    TimelineScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _playerAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _playerExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _playerAnimController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _playerAnimController.addListener(() {
      setState(() {
        _playerExpandValue = _playerAnimController.value;
      });
    });
  }

  @override
  void dispose() {
    _playerAnimController.dispose();
    super.dispose();
  }

  void _expandPlayer() {
    if (!context.read<PlayerService>().hasContent) return;
    _playerAnimController.forward();
  }

  void _collapsePlayer() {
    _playerAnimController.reverse();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        _playerAnimController.forward();
      } else {
        _playerAnimController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final topInset = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;

    // If fullscreen, show player as a full page
    if (_isFullscreen && player.hasContent) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(child: FullPlayerSheet(onCollapse: _toggleFullscreen)),
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) {
                  setState(() => _currentIndex = i);
                  _toggleFullscreen();
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.rss_feed_outlined),
                    selectedIcon: Icon(Icons.rss_feed),
                    label: 'Feed',
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
      );
    }

    // Normal view: minimized + expanded overlay
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
              if (player.hasContent)
                GestureDetector(
                  onTap: _expandPlayer,
                  child: const MiniPlayerBar(),
                ),
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (i) {
                    setState(() => _currentIndex = i);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.rss_feed_outlined),
                      selectedIcon: Icon(Icons.rss_feed),
                      label: 'Feed',
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
          // Expanded overlay (covers nav bar when expanding)
          if (player.hasContent && _playerExpandValue > 0)
            GestureDetector(
              onVerticalDragUpdate: (details) {
                final delta = details.primaryDelta ?? 0;
                _playerAnimController.value -= delta / screenHeight;
              },
              onVerticalDragEnd: (details) {
                // Snap to fullscreen or collapse
                if (_playerAnimController.value > 0.7) {
                  setState(() => _isFullscreen = true);
                  _playerAnimController.forward();
                } else {
                  _playerAnimController.reverse();
                }
              },
              child: Transform.translate(
                offset: Offset(0, (1 - _playerExpandValue) * 60),
                child: Container(
                  height:
                      screenHeight - topInset - (60 * (1 - _playerExpandValue)),
                  color: Colors.black.withValues(alpha: 0.95),
                  child: FullPlayerSheet(onCollapse: _collapsePlayer),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
