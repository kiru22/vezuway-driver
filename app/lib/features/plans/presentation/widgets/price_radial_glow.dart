import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PriceRadialGlow extends StatelessWidget {
  final Color accent;

  const PriceRadialGlow({
    super.key,
    required this.accent,
  });

  static const _centerOpacity = 0.30;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: 40,
        sigmaY: 30,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: 160,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(40),
          color: accent.withValues(alpha: _centerOpacity),
        ),
      ),
    );
  }
}
