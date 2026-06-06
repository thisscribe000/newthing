import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class ArtworkWidget extends StatelessWidget {
  final String? imageUrl;
  final String emoji;
  final double size;
  final double borderRadius;
  final bool isActive;

  const ArtworkWidget({
    super.key,
    this.imageUrl,
    required this.emoji,
    this.size = 52,
    this.borderRadius = 14,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => _EmojiFallback(
            emoji: emoji,
            size: size,
            borderRadius: borderRadius,
            isActive: isActive,
          ),
          errorWidget: (_, _, _) => _EmojiFallback(
            emoji: emoji,
            size: size,
            borderRadius: borderRadius,
            isActive: isActive,
          ),
        ),
      );
    }

    return _EmojiFallback(
      emoji: emoji,
      size: size,
      borderRadius: borderRadius,
      isActive: isActive,
    );
  }
}

class _EmojiFallback extends StatelessWidget {
  final String emoji;
  final double size;
  final double borderRadius;
  final bool isActive;

  const _EmojiFallback({
    required this.emoji,
    required this.size,
    required this.borderRadius,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}
