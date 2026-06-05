import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/radio_station.dart';
import '../models/podcast.dart';
import '../models/podcast_clip.dart';
import '../services/player_service.dart';
import '../services/podcast_service.dart';
import '../services/clip_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_top_bar.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: WavelineColors.bg,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientTopBar(
                title: 'Library',
                height: 140,
                trailing: Container(
                  decoration: BoxDecoration(
                    color: WavelineColors.surface3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WavelineColors.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.sort_rounded,
                          color: WavelineColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: WavelineColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: WavelineColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: WavelineColors.accent,
                  unselectedLabelColor: WavelineColors.textMuted,
                  labelStyle: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.dmSans(
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Radio'),
                    Tab(text: 'Podcasts'),
                    Tab(text: 'Clips'),
                    Tab(text: 'Favorites'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _RadioTab(),
            _PodcastsTab(),
            _ClipsTab(),
            _FavoritesTab(),
          ],
        ),
      ),
    );
  }
}

class _RadioTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        _SearchField(),
        const SizedBox(height: 16),
        ...RadioStation.seedStations.map(
          (station) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StationCard(station: station),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search radio, podcasts...',
        prefixIcon: Icon(Icons.search_rounded, color: WavelineColors.textDim),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: WavelineColors.textDim),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                },
              )
            : null,
      ),
      style: GoogleFonts.dmSans(fontSize: 14, color: WavelineColors.textPrimary),
      onChanged: (_) => setState(() {}),
    );
  }
}

class _StationCard extends StatelessWidget {
  final RadioStation station;

  const _StationCard({required this.station});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final isActive = player.currentStation?.id == station.id;

    return Container(
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? WavelineColors.accent.withValues(alpha: 0.4)
              : WavelineColors.border,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.read<PlayerService>().playStation(station),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isActive
                            ? WavelineColors.accent.withValues(alpha: 0.3)
                            : WavelineColors.surface3,
                        WavelineColors.surface2,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(station.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WavelineColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${station.genre} \u00b7 ${station.country}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: WavelineColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: WavelineColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: WavelineColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            color: WavelineColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    '${station.listeners}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: WavelineColors.textDim,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PodcastsTab extends StatefulWidget {
  @override
  State<_PodcastsTab> createState() => _PodcastsTabState();
}

class _PodcastsTabState extends State<_PodcastsTab> {
  PodcastShow? _activeShow;
  final Map<String, List<PodcastEpisode>> _episodes = {};
  final Map<String, bool> _loading = {};

  @override
  void initState() {
    super.initState();
    _loadEpisodes(PodcastShow.seedShows.first);
  }

  Future<void> _loadEpisodes(PodcastShow show) async {
    setState(() {
      _activeShow = show;
      _loading[show.id] = true;
    });
    final service = context.read<PodcastService>();
    final episodes = await service.fetchEpisodes(show);
    if (mounted) {
      setState(() {
        _episodes[show.id] = episodes;
        _loading[show.id] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: PodcastShow.seedShows.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final show = PodcastShow.seedShows[index];
              final isActive = _activeShow?.id == show.id;
              return GestureDetector(
                onTap: () => _loadEpisodes(show),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? WavelineColors.accent.withValues(alpha: 0.15)
                        : WavelineColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? WavelineColors.accent.withValues(alpha: 0.4)
                          : WavelineColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(show.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        show.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: WavelineColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ..._buildEpisodeList(),
      ],
    );
  }

  List<Widget> _buildEpisodeList() {
    if (_activeShow == null) return [];
    final show = _activeShow!;

    if (_loading[show.id] == true) {
      return List.generate(5, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: WavelineColors.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ));
    }

    final episodes = _episodes[show.id] ?? [];
    if (episodes.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              'No episodes found',
              style: GoogleFonts.dmSans(color: WavelineColors.textMuted),
            ),
          ),
        ),
      ];
    }

    return episodes.map((episode) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _EpisodeCard(episode: episode),
    )).toList();
  }
}

class _EpisodeCard extends StatelessWidget {
  final PodcastEpisode episode;

  const _EpisodeCard({required this.episode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WavelineColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.read<PlayerService>().playEpisode(episode),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: WavelineColors.surface3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(episode.showEmoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: WavelineColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${episode.durationFormatted} \u00b7 ${episode.publishedFormatted}',
                        style: GoogleFonts.dmMono(
                          fontSize: 10,
                          color: WavelineColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClipsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClipService>(
      builder: (context, clipService, _) {
        final clips = clipService.clips;
        if (clips.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.content_cut_rounded, size: 48, color: WavelineColors.textDim),
                const SizedBox(height: 12),
                Text(
                  'No clips saved yet',
                  style: GoogleFonts.dmSans(fontSize: 14, color: WavelineColors.textMuted),
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: clips.map((clip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ClipCard(clip: clip),
          )).toList(),
        );
      },
    );
  }
}

class _ClipCard extends StatelessWidget {
  final PodcastClip clip;

  const _ClipCard({required this.clip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WavelineColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WavelineColors.surface3,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(clip.showEmoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clip.episodeTitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WavelineColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          clip.timeRangeFormatted,
                          style: GoogleFonts.dmMono(
                            fontSize: 11,
                            color: WavelineColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          clip.durationFormatted,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: WavelineColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.read<ClipService>().deleteClip(clip.id),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: WavelineColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_outline_rounded, size: 48, color: WavelineColors.textDim),
          const SizedBox(height: 12),
          Text(
            'Favorite stations and episodes\nwill appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 14, color: WavelineColors.textMuted),
          ),
        ],
      ),
    );
  }
}
