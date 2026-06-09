import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AlbumArtCollage extends StatelessWidget {
  final List<String> emojis;
  final double height;

  const AlbumArtCollage({
    super.key,
    required this.emojis,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (emojis.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              WavelineColors.accent.withValues(alpha: 0.08),
              WavelineColors.surface2,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.music_note_rounded,
            size: 48,
            color: WavelineColors.textDim,
          ),
        ),
      );
    }

    final items = emojis.take(4).toList();
    while (items.length < 4) {
      items.add('🎵');
    }

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          for (int i = 0; i < items.length; i++)
            Positioned(
              left: _positions[i].dx * (height - 60),
              top: _positions[i].dy * (height - 60),
              child: Transform.rotate(
                angle: _rotations[i],
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _colors[i].withValues(alpha: 0.3),
                        _colors[i].withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16 + _rotations[i] * 4),
                    border: Border.all(
                      color: _colors[i].withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(items[i], style: const TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const _positions = [
  Offset(0.05, 0.1),
  Offset(0.35, 0.0),
  Offset(0.55, 0.25),
  Offset(0.15, 0.35),
];

const _rotations = [
  -0.1,
  0.15,
  -0.08,
  0.12,
];

const _colors = [
  WavelineColors.accent,
  WavelineColors.pink,
  WavelineColors.cyan,
  WavelineColors.gold,
];
