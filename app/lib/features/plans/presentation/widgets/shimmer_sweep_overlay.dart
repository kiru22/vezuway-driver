import 'dart:math' as math;

import 'package:flutter/material.dart';

class ShimmerSweepOverlay extends StatefulWidget {
  final bool isActive;
  final double borderRadius;
  final Color? accent;

  const ShimmerSweepOverlay({
    super.key,
    required this.isActive,
    required this.borderRadius,
    this.accent,
  });

  @override
  State<ShimmerSweepOverlay> createState() => _ShimmerSweepOverlayState();
}

class _ShimmerSweepOverlayState extends State<ShimmerSweepOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerSweepOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _RealisticShimmerPainter(
              progress: _controller.value,
              isDark: isDark,
              accent: widget.accent,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RealisticShimmerPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color? accent;

  _RealisticShimmerPainter({
    required this.progress,
    required this.isDark,
    this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Active during 0.0 → 0.30, rest is pause
    if (progress > 0.30) return;

    // Normalize + apply easing for realistic light acceleration
    final t = Curves.easeInOutCubic.transform(progress / 0.30);

    final diagonal =
        math.sqrt(size.width * size.width + size.height * size.height);
    final angle = math.atan2(size.height, size.width);

    canvas.save();
    canvas.translate(0, size.height);
    canvas.rotate(-angle);

    // --- Layer 1: Broad soft glow (wide, low opacity) ---
    final broadWidth = 120.0;
    final broadCenter = -broadWidth / 2 + t * (diagonal + broadWidth);
    final broadRect = Rect.fromLTWH(
      broadCenter - broadWidth / 2,
      -size.height,
      broadWidth,
      diagonal * 2,
    );

    final glowColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : (accent ?? const Color(0xFF10B981)).withValues(alpha: 0.05);

    final broadPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          glowColor,
          glowColor,
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(broadRect);

    canvas.drawRect(broadRect, broadPaint);

    // --- Layer 2: Sharp highlight (narrow, higher opacity) ---
    final sharpWidth = 35.0;
    final sharpCenter = -sharpWidth / 2 + t * (diagonal + sharpWidth);
    final sharpRect = Rect.fromLTWH(
      sharpCenter - sharpWidth / 2,
      -size.height,
      sharpWidth,
      diagonal * 2,
    );

    final highlightOpacity = isDark ? 0.14 : 0.10;
    final highlightColor = Colors.white.withValues(alpha: highlightOpacity);

    final sharpPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          highlightColor,
          highlightColor,
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(sharpRect);

    canvas.drawRect(sharpRect, sharpPaint);

    // --- Layer 3: Chromatic edge (very thin, accent tinted) ---
    final edgeWidth = 8.0;
    // Slightly ahead of the sharp highlight
    final edgeCenter = sharpCenter + sharpWidth * 0.4;
    final edgeRect = Rect.fromLTWH(
      edgeCenter - edgeWidth / 2,
      -size.height,
      edgeWidth,
      diagonal * 2,
    );

    final edgeColor =
        (accent ?? const Color(0xFF10B981)).withValues(alpha: isDark ? 0.12 : 0.08);

    final edgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          edgeColor,
          Colors.transparent,
        ],
      ).createShader(edgeRect);

    canvas.drawRect(edgeRect, edgePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RealisticShimmerPainter old) =>
      old.progress != progress;
}
