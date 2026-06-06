import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WavySlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool isPlaying;
  final Color activeColor;
  final Color inactiveColor;

  const WavySlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.isPlaying = true,
    this.activeColor = WavelineColors.accent,
    this.inactiveColor = WavelineColors.border,
  });

  @override
  State<WavySlider> createState() => _WavySliderState();
}

class _WavySliderState extends State<WavySlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = 56.0;
        final trackHeight = 4.0;
        final thumbRadius = 8.0;
        final availableWidth = width - thumbRadius * 2;
        final progress = widget.value.clamp(0.0, 1.0);

        return GestureDetector(
          onTapDown: (details) {
            final pos = (details.localPosition.dx - thumbRadius) / availableWidth;
            widget.onChanged?.call(pos.clamp(0.0, 1.0));
          },
          onHorizontalDragStart: (_) => setState(() => _isDragging = true),
          onHorizontalDragUpdate: (details) {
            final pos = (details.localPosition.dx - thumbRadius) / availableWidth;
            widget.onChanged?.call(pos.clamp(0.0, 1.0));
          },
          onHorizontalDragEnd: (details) {
            setState(() => _isDragging = false);
            widget.onChangeEnd?.call(widget.value);
          },
          child: SizedBox(
            width: width,
            height: height,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(width, height),
                    painter: _WavySliderPainter(
                      progress: progress,
                      waveValue: math.sin(_waveController.value * 2 * math.pi),
                      isPlaying: widget.isPlaying,
                      isDragging: _isDragging,
                      activeColor: widget.activeColor,
                      inactiveColor: widget.inactiveColor,
                      trackHeight: trackHeight,
                      thumbRadius: thumbRadius,
                    ),
                  );
                },
              ),
          ),
        );
      },
    );
  }
}

class _WavySliderPainter extends CustomPainter {
  final double progress;
  final double waveValue;
  final bool isPlaying;
  final bool isDragging;
  final Color activeColor;
  final Color inactiveColor;
  final double trackHeight;
  final double thumbRadius;

  _WavySliderPainter({
    required this.progress,
    required this.waveValue,
    required this.isPlaying,
    required this.isDragging,
    required this.activeColor,
    required this.inactiveColor,
    required this.trackHeight,
    required this.thumbRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final halfHeight = size.height / 2;
    final availableWidth = size.width - thumbRadius * 2;
    final thumbX = thumbRadius + progress * availableWidth;

    _drawInactiveTrack(canvas, size, halfHeight, availableWidth, thumbX);
    _drawActiveTrack(canvas, size, halfHeight, availableWidth, thumbX);
    _drawWave(canvas, size, halfHeight, availableWidth, thumbX);
    _drawThumb(canvas, thumbX, halfHeight);
  }

  void _drawInactiveTrack(Canvas canvas, Size size, double halfHeight,
      double availableWidth, double thumbX) {
    final paint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX + (size.width - thumbX) / 2, halfHeight),
        width: size.width - thumbX,
        height: trackHeight,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, paint);
  }

  void _drawActiveTrack(Canvas canvas, Size size, double halfHeight,
      double availableWidth, double thumbX) {
    final paint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX / 2, halfHeight),
        width: thumbX,
        height: trackHeight,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, paint);
  }

  void _drawWave(Canvas canvas, Size size, double halfHeight,
      double availableWidth, double thumbX) {
    final amplitude = isDragging || !isPlaying
        ? 0.0
        : 3.0 * (0.3 + 0.7 * (1 - progress));
    if (amplitude < 0.3) return;

    final paint = Paint()
      ..color = activeColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final startX = thumbX;
    final endX = size.width;

    path.moveTo(startX, halfHeight - trackHeight / 2);
    for (double x = startX; x <= endX; x += 2) {
      final wave = math.sin((x - startX) * 0.08 + waveValue * 2 * math.pi);
      final y = halfHeight - trackHeight / 2 + wave * amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(endX, halfHeight + trackHeight / 2);
    for (double x = endX; x >= startX; x -= 2) {
      final wave = math.sin((x - startX) * 0.08 + waveValue * 2 * math.pi);
      final y = halfHeight + trackHeight / 2 + wave * amplitude;
      path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawThumb(Canvas canvas, double thumbX, double halfHeight) {
    final radius = isDragging ? thumbRadius * 1.2 : thumbRadius;

    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(thumbX, halfHeight), radius * 2, glowPaint);

    final thumbPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, halfHeight), radius, thumbPaint);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, halfHeight), radius * 0.4, innerPaint);
  }

  @override
  bool shouldRepaint(_WavySliderPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      waveValue != oldDelegate.waveValue ||
      isPlaying != oldDelegate.isPlaying ||
      isDragging != oldDelegate.isDragging ||
      activeColor != oldDelegate.activeColor ||
      inactiveColor != oldDelegate.inactiveColor ||
      trackHeight != oldDelegate.trackHeight ||
      thumbRadius != oldDelegate.thumbRadius;
}


