import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  double get _w => MediaQuery.of(context).size.width;
  double get _h => MediaQuery.of(context).size.height;

  double get headerHeight => (_h * 0.22).clamp(140, 260);
  double get libraryHeaderHeight => (_h * 0.16).clamp(120, 180);
  double get albumArtSize => (_w * 0.72).clamp(200, 320);
  double get collageHeight => (_w * 0.45).clamp(140, 220);
  double get emptyStateHeight => (_h * 0.18).clamp(120, 200);
  double get mixSectionHeight => (_w * 0.5).clamp(160, 200);
  double get cardWidth => (_w * 0.36).clamp(120, 160);
  double get podcastCardWidth => (_w * 0.34).clamp(110, 150);
}
