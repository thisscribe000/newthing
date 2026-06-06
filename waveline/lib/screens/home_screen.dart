import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/radio_station.dart';
import '../models/podcast.dart' show PodcastShow;
import '../models/timeline_entry.dart' show TimelineEntry, TimelineEntryType;
import '../services/player_service.dart';
import '../services/podcast_service.dart';
import '../services/listening_history.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_top_bar.dart';
import '../widgets/album_art_collage.dart';
import '../widgets/artwork.dart';
import '../widgets/station_card.dart';
import '../widgets/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerService, ListeningHistory>(
      builder: (context, player, history, _) {
        final recentEntries = history.entries;
        final emojis = recentEntries
            .take(4)
            .map((e) => e.emoji)
            .toList();
        final lastPodcastEntry = recentEntries.cast<TimelineEntry?>().firstWhere(
          (e) => e!.type == TimelineEntryType.podcast,
          orElse: () => null,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: Responsive(context).headerHeight,
                pinned: false,
                floating: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: GradientTopBar(
                    title: 'Waveline',
                    subtitle: 'LISTEN DIFFERENTLY',
                    height: Responsive(context).headerHeight,
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
                              Icons.tune_rounded,
                              color: WavelineColors.textMuted,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionHeader(title: 'Your Mix'),
                    const SizedBox(height: 12),
                    _YourMixSection(
                      player: player,
                      height: Responsive(context).mixSectionHeight,
                    ),
                    const SizedBox(height: 24),
                    if (lastPodcastEntry != null) ...[
                      _SectionHeader(title: 'Continue Listening'),
                      const SizedBox(height: 12),
                      _ContinueListeningCard(entry: lastPodcastEntry),
                      const SizedBox(height: 24),
                    ],
                    _SectionHeader(title: 'Recently Played'),
                    const SizedBox(height: 12),
                    if (recentEntries.isEmpty)
                      _EmptyState(
                        icon: Icons.history_rounded,
                        message: 'Start listening to see\nyour history here',
                        height: Responsive(context).emptyStateHeight,
                      )
                    else
                      _RecentCollage(
                        emojis: emojis,
                        height: Responsive(context).collageHeight,
                      ),
                    const SizedBox(height: 24),
                    if (recentEntries.isNotEmpty) ...[
                      _SectionHeader(title: 'Listening History'),
                      const SizedBox(height: 12),
                      ...recentEntries.take(5).map(
                        (entry) => _HistoryItem(entry: entry),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Trending Stations'),
                    const SizedBox(height: 12),
                    ...RadioStation.seedStations.take(4).map(
                      (station) => StationCard(station: station),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Trending Podcasts'),
                    const SizedBox(height: 12),
                    _PodcastShowSection(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: WavelineColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _YourMixSection extends StatelessWidget {
  final PlayerService player;
  final double height;

  const _YourMixSection({required this.player, this.height = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: RadioStation.seedStations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final station = RadioStation.seedStations[index];
          final isActive = player.currentStation?.id == station.id;

          return GestureDetector(
            onTap: () => context.read<PlayerService>().playStation(station),
            child: Container(
              width: Responsive(context).cardWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isActive
                        ? WavelineColors.accent.withValues(alpha: 0.2)
                        : WavelineColors.surface2,
                    WavelineColors.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? WavelineColors.accent.withValues(alpha: 0.4)
                      : WavelineColors.border,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ArtworkWidget(
                    imageUrl: station.imageUrl,
                    emoji: station.emoji,
                    size: 64,
                    borderRadius: 16,
                    isActive: isActive,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      station.name,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WavelineColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    station.genre,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: WavelineColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContinueListeningCard extends StatelessWidget {
  final TimelineEntry entry;

  const _ContinueListeningCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WavelineColors.accent.withValues(alpha: 0.12),
            WavelineColors.surface2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: WavelineColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final player = context.read<PlayerService>();
            final podcastService = context.read<PodcastService>();
            for (final show in PodcastShow.seedShows) {
              podcastService.fetchEpisodes(show).then((episodes) {
                final episode = episodes.where((e) => e.id == entry.id).firstOrNull;
                if (episode != null) {
                  player.playEpisode(episode);
                }
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ArtworkWidget(
                  emoji: entry.emoji,
                  size: 56,
                  borderRadius: 14,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WavelineColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        entry.subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: WavelineColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: WavelineColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 16,
                        color: WavelineColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Resume',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: WavelineColors.accent,
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

class _PodcastShowSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive(context).mixSectionHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PodcastShow.seedShows.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final show = PodcastShow.seedShows[index];
          return GestureDetector(
            onTap: () {
              final player = context.read<PlayerService>();
              final podcastService = context.read<PodcastService>();
              podcastService.fetchEpisodes(show).then((episodes) {
                if (episodes.isNotEmpty) {
                  player.playEpisode(episodes.first);
                }
              });
            },
            child: Container(
              width: Responsive(context).podcastCardWidth,
              decoration: BoxDecoration(
                color: WavelineColors.surface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WavelineColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ArtworkWidget(
                    imageUrl: show.imageUrl,
                    emoji: show.emoji,
                    size: 60,
                    borderRadius: 14,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      show.title,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WavelineColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentCollage extends StatelessWidget {
  final List<String> emojis;
  final double height;

  const _RecentCollage({required this.emojis, this.height = 180});

  @override
  Widget build(BuildContext context) {
    return AlbumArtCollage(emojis: emojis, height: height);
  }
}

class _HistoryItem extends StatelessWidget {
  final TimelineEntry entry;

  const _HistoryItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: WavelineColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WavelineColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final player = context.read<PlayerService>();
              if (entry.type == TimelineEntryType.radio) {
                final station = RadioStation.seedStations
                    .where((s) => s.id == entry.id)
                    .firstOrNull;
                if (station != null) player.playStation(station);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ArtworkWidget(
                    emoji: entry.emoji,
                    size: 44,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: WavelineColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: WavelineColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(entry.playedAt),
                    style: GoogleFonts.dmMono(
                      fontSize: 11,
                      color: WavelineColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final double height;

  const _EmptyState({required this.icon, required this.message, this.height = 160});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WavelineColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: WavelineColors.textDim),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: WavelineColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
