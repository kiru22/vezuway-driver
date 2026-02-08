import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PlanBackgroundOrbs extends StatelessWidget {
  final Color accent;
  final double pageOffset;

  const PlanBackgroundOrbs({
    super.key,
    required this.accent,
    required this.pageOffset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseOpacity = isDark ? 0.20 : 0.15;

    // Parallax offset based on page position (subtle movement)
    final parallaxX = (pageOffset - 1.0) * 30;

    return Stack(
      children: [
        // Top-right orb — large accent
        Positioned(
          top: -80,
          right: -60 + parallaxX,
          child: _BlurredOrb(
            size: 320,
            color: accent.withValues(alpha: baseOpacity),
            blurAmount: 80,
          ),
        ),
        // Bottom-left orb — complementary
        Positioned(
          bottom: -100,
          left: -80 - parallaxX,
          child: _BlurredOrb(
            size: 280,
            color: AppColors.primary.withValues(alpha: baseOpacity * 0.7),
            blurAmount: 90,
          ),
        ),
        // Center orb — subtle, moves with parallax
        Positioned(
          top: 200,
          left: 100 + parallaxX * 2,
          child: _BlurredOrb(
            size: 200,
            color: accent.withValues(alpha: baseOpacity * 0.5),
            blurAmount: 70,
          ),
        ),
      ],
    );
  }
}

class _BlurredOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double blurAmount;

  const _BlurredOrb({
    required this.size,
    required this.color,
    required this.blurAmount,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: blurAmount,
        sigmaY: blurAmount,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
