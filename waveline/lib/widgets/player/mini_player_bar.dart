import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../services/player_service.dart';
import '../../theme/app_theme.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, player, _) {
        if (!player.hasContent) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                WavelineColors.accentDark.withValues(alpha: 0.3),
                WavelineColors.bg.withValues(alpha: 0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              top: BorderSide(color: WavelineColors.accent.withValues(alpha: 0.15)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      WavelineColors.accent.withValues(alpha: 0.3),
                      WavelineColors.surface3,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: WavelineColors.border),
                ),
                child: Center(
                  child: Text(
                    player.nowPlayingEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.nowPlayingTitle,
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
                      player.nowPlayingSubtitle,
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
              _PlayerControls(player: player),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerControls extends StatelessWidget {
  final PlayerService player;

  const _PlayerControls({required this.player});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (player.type == NowPlayingType.podcast)
              _IconButton(
                icon: Icons.timer_outlined,
                onTap: () {},
              ),
            const SizedBox(width: 4),
            Container(
              decoration: BoxDecoration(
                color: WavelineColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: WavelineColors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => player.togglePlay(),
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WavelineColors.surface3.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: WavelineColors.textMuted, size: 20),
          ),
        ),
      ),
    );
  }
}
