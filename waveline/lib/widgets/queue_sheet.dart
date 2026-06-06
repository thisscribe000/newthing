import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/queue_item.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import 'artwork.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, player, _) {
        final queue = player.queue;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: WavelineColors.gradientPlayer,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: WavelineColors.textDim,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queue',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: WavelineColors.textPrimary,
                        ),
                      ),
                      if (queue.isNotEmpty)
                        GestureDetector(
                          onTap: () => player.clearQueue(),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: WavelineColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (queue.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.queue_music_rounded,
                            size: 48,
                            color: WavelineColors.textDim,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Queue is empty',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: WavelineColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add stations or episodes to play next',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: WavelineColors.textDim,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final item = queue[index];
                          final isCurrent = index == player.queueIndex;
                          return _QueueRow(
                            item: item,
                            index: index,
                            isCurrent: isCurrent,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QueueRow extends StatelessWidget {
  final QueueItem item;
  final int index;
  final bool isCurrent;

  const _QueueRow({
    required this.item,
    required this.index,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isCurrent
              ? WavelineColors.accent.withValues(alpha: 0.1)
              : WavelineColors.surface2.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? WavelineColors.accent.withValues(alpha: 0.3)
                : WavelineColors.border,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.read<PlayerService>().playFromQueue(index),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ArtworkWidget(
                    imageUrl: item.imageUrl,
                    emoji: item.emoji,
                    size: 40,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? WavelineColors.accent
                                : WavelineColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: WavelineColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isCurrent)
                    GestureDetector(
                      onTap: () => context.read<PlayerService>().removeFromQueue(index),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
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
