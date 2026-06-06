import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/radio_station.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import 'artwork.dart';

class StationCard extends StatelessWidget {
  final RadioStation station;
  final bool compact;
  final VoidCallback? onTap;

  const StationCard({
    super.key,
    required this.station,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final isActive = player.currentStation?.id == station.id;
    final isLoading = isActive && player.isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: Container(
        decoration: BoxDecoration(
          color: WavelineColors.surface2,
          borderRadius: BorderRadius.circular(compact ? 12 : 14),
          border: Border.all(
            color: isActive
                ? WavelineColors.accentBright.withValues(alpha: 0.4)
                : WavelineColors.border,
            width: isActive && !compact ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(compact ? 12 : 14),
            onTap: onTap ?? () => context.read<PlayerService>().playStation(station),
            child: Padding(
              padding: EdgeInsets.all(compact ? 12 : 14),
              child: Row(
                children: [
                  _EmojiBox(station: station, isActive: isActive, compact: compact),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: GoogleFonts.nunito(
                            fontSize: compact ? 14 : 15,
                            fontWeight: FontWeight.w700,
                            color: WavelineColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${station.genre} \u00b7 ${station.country}',
                          style: GoogleFonts.dmSans(
                            fontSize: compact ? 11 : 12,
                            color: WavelineColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: WavelineColors.accent,
                      ),
                    )
                  else if (isActive)
                    _LiveBadge(compact: compact)
                  else if (!compact)
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

class _EmojiBox extends StatelessWidget {
  final RadioStation station;
  final bool isActive;
  final bool compact;

  const _EmojiBox({
    required this.station,
    required this.isActive,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 52.0;
    final radius = compact ? 12.0 : 14.0;

    return ArtworkWidget(
      imageUrl: station.imageUrl,
      emoji: station.emoji,
      size: size,
      borderRadius: radius,
      isActive: isActive,
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool compact;

  const _LiveBadge({required this.compact});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: WavelineColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'LIVE',
          style: GoogleFonts.dmMono(
            fontSize: 9,
            color: WavelineColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
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
    );
  }
}
