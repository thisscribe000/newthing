import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/radio_station.dart';
import '../models/timeline_entry.dart';
import '../services/player_service.dart';
import '../services/listening_history.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_top_bar.dart';
import '../widgets/album_art_collage.dart';

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

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: false,
                floating: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: GradientTopBar(
                    title: 'Waveline',
                    subtitle: 'LISTEN DIFFERENTLY',
                    height: 200,
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
                    _YourMixSection(player: player),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Recently Played'),
                    const SizedBox(height: 12),
                    if (recentEntries.isEmpty)
                      _EmptyState(
                        icon: Icons.history_rounded,
                        message: 'Start listening to see\nyour history here',
                      )
                    else
                      _RecentCollage(emojis: emojis),
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
                      (station) => _StationRow(station: station),
                    ),
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

  const _YourMixSection({required this.player});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
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
              width: 140,
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
                  Container(
                    width: 64,
                    height: 64,
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(station.emoji, style: const TextStyle(fontSize: 28)),
                    ),
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

class _RecentCollage extends StatelessWidget {
  final List<String> emojis;

  const _RecentCollage({required this.emojis});

  @override
  Widget build(BuildContext context) {
    return AlbumArtCollage(emojis: emojis, height: 180);
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
              if (entry.type == 'radio') {
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: WavelineColors.surface3,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(entry.emoji, style: const TextStyle(fontSize: 20)),
                    ),
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

class _StationRow extends StatelessWidget {
  final RadioStation station;

  const _StationRow({required this.station});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final isActive = player.currentStation?.id == station.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: WavelineColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? WavelineColors.accent.withValues(alpha: 0.4)
                : WavelineColors.border,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.read<PlayerService>().playStation(station),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(station.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: WavelineColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: WavelineColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
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
                              fontSize: 9,
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
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
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
