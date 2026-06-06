import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/timeline_entry.dart' show TimelineEntry, TimelineEntryType;
import '../models/radio_station.dart';
import '../services/player_service.dart';
import '../services/listening_history.dart';
import '../theme/app_theme.dart';
import '../widgets/artwork.dart';
import '../widgets/responsive.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: Responsive(context).libraryHeaderHeight,
            pinned: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      WavelineColors.accentDark.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'History',
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: WavelineColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Consumer<ListeningHistory>(
                  builder: (context, history, _) {
                    final entries = history.entries;
                    if (entries.isEmpty) {
                      return _EmptyHistory();
                    }

                    final grouped = _groupEntries(entries);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: grouped.entries.map((group) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DateLabel(group.key),
                            const SizedBox(height: 8),
                            ...group.value.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _HistoryCard(entry: entry),
                            )),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<TimelineEntry>> _groupEntries(List<TimelineEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<TimelineEntry>>{};
    for (final entry in entries) {
      final day = DateTime(entry.playedAt.year, entry.playedAt.month, entry.playedAt.day);
      String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = '${day.month}/${day.day}/${day.year}';
      }
      grouped.putIfAbsent(label, () => []).add(entry);
    }
    return grouped;
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: WavelineColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WavelineColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: WavelineColors.textDim),
            const SizedBox(height: 16),
            Text(
              'No listening history yet',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WavelineColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Play a station or podcast to get started',
              style: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  final String label;
  const _DateLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 11,
        letterSpacing: 1.5,
        color: WavelineColors.textMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TimelineEntry entry;
  const _HistoryCard({required this.entry});

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
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }
}
