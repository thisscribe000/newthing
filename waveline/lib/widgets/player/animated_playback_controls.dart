import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnimatedPlaybackControls extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const AnimatedPlaybackControls({
    super.key,
    required this.isPlaying,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  State<AnimatedPlaybackControls> createState() => _AnimatedPlaybackControlsState();
}

class _AnimatedPlaybackControlsState extends State<AnimatedPlaybackControls>
    with SingleTickerProviderStateMixin {
  String? _lastClicked;
  void _handlePress(String button) {
    setState(() {
      _lastClicked = button;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _lastClicked = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            label: 'previous',
            isExpanded: _lastClicked == 'previous',
            onTap: () {
              _handlePress('previous');
              widget.onPrevious();
            },
          ),
          const SizedBox(width: 8),
          _PlayPauseButton(
            isPlaying: widget.isPlaying,
            isExpanded: _lastClicked == 'play_pause',
            onTap: () {
              _handlePress('play_pause');
              widget.onPlayPause();
            },
          ),
          const SizedBox(width: 8),
          _ControlButton(
            icon: Icons.skip_next_rounded,
            label: 'next',
            isExpanded: _lastClicked == 'next',
            onTap: () {
              _handlePress('next');
              widget.onNext();
            },
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedScale(
        scale: isExpanded ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 80,
          decoration: BoxDecoration(
            color: isExpanded
                ? WavelineColors.accent.withValues(alpha: 0.2)
                : WavelineColors.surface3.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExpanded
                  ? WavelineColors.accent.withValues(alpha: 0.3)
                  : WavelineColors.borderLight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Icon(
                  icon,
                  color: isExpanded
                      ? WavelineColors.accentLight
                      : WavelineColors.textSecondary,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isExpanded;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: AnimatedScale(
        scale: isExpanded ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isExpanded
                    ? WavelineColors.accentLight
                    : WavelineColors.accent,
                WavelineColors.accentLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: WavelineColors.accent.withValues(alpha: isExpanded ? 0.5 : 0.3),
                blurRadius: isExpanded ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(isPlaying),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
