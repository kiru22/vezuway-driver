import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final LinearGradient gradient;
  final double borderRadius;
  final double strokeWidth;
  final double opacity;

  GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.strokeWidth,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final half = strokeWidth / 2;
    final insetRect = rect.deflate(half);
    final rrect = RRect.fromRectAndRadius(
        insetRect, Radius.circular(borderRadius - half));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.saveLayer(
        rect, Paint()..color = Colors.white.withValues(alpha: opacity));
    canvas.drawRRect(rrect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GradientBorderPainter old) =>
      old.opacity != opacity || old.strokeWidth != strokeWidth;
}
