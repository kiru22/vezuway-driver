import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'gooey_base.dart';

class GooeySwitch extends GooeyBaseWidget {
  const GooeySwitch({
    super.key,
    required super.value,
    required super.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.scale = 1.0,
    super.enabled,
  });

  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double scale;

  @override
  State<GooeySwitch> createState() => _GooeySwitchState();
}

class _GooeySwitchState extends GooeyBaseState<GooeySwitch> {
  static const _baseWidth = 56.0;
  static const _baseHeight = 32.0;
  static const _thumbPadding = 3.0;

  @override
  double get trackWidth => _baseWidth * widget.scale;

  @override
  double get trackHeight => _baseHeight * widget.scale;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final activeColor = widget.activeColor ?? AppColors.primary;
    final inactiveColor = widget.inactiveColor ??
        (brightness == Brightness.dark
            ? Color.lerp(AppColors.background, AppColors.surface, 0.25)!
            : AppColors.lightBorder);
    final thumbColor = widget.thumbColor ?? Colors.white;

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: handleTap,
        onHorizontalDragStart: handleDragStart,
        onHorizontalDragUpdate: handleDragUpdate,
        onHorizontalDragEnd: handleDragEnd,
        child: AnimatedBuilder(
          animation:
              Listenable.merge([positionController, deformController]),
          builder: (context, _) {
            return CustomPaint(
              size: Size(trackWidth, trackHeight),
              painter: _GooeyPainter(
                position: positionController.value,
                deform: deformCurve(deformController.value),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                thumbColor: thumbColor,
                padding: _thumbPadding * widget.scale,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GooeyPainter extends CustomPainter {
  _GooeyPainter({
    required this.position,
    required this.deform,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.padding,
  });

  final double position;
  final double deform;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRadius = size.height / 2;
    final thumbRadius = (size.height / 2) - padding;
    final trackColor = Color.lerp(inactiveColor, activeColor, position)!;

    final minX = padding + thumbRadius;
    final maxX = size.width - padding - thumbRadius;
    final thumbCx = minX + (maxX - minX) * position;
    final thumbCy = size.height / 2;

    final stretchX = 1.0 + (GooeyBaseState.stretchX - 1.0) * deform;
    final squishY = 1.0 - (1.0 - GooeyBaseState.squishY) * deform;

    final blurSigma = size.height * 0.35;
    final layerPaint = Paint()
      ..imageFilter = ui.ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
      );

    canvas.saveLayer(Offset.zero & size, layerPaint);

    final trackPaint = Paint()..color = trackColor;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(trackRadius),
    );
    canvas.drawRRect(trackRect, trackPaint);

    final thumbPaint = Paint()..color = thumbColor;
    canvas.save();
    canvas.translate(thumbCx, thumbCy);
    canvas.scale(stretchX, squishY);
    canvas.drawCircle(Offset.zero, thumbRadius, thumbPaint);
    canvas.restore();

    canvas.restore();

    final crispTrackPaint = Paint()..color = trackColor;
    final crispTrackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(trackRadius - 1),
    );
    canvas.drawRRect(crispTrackRect, crispTrackPaint);

    final crispThumbPaint = Paint()..color = thumbColor;
    final crispRadius = thumbRadius * 0.85;
    canvas.save();
    canvas.translate(thumbCx, thumbCy);
    canvas.scale(stretchX, squishY);
    canvas.drawCircle(Offset.zero, crispRadius, crispThumbPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GooeyPainter oldDelegate) =>
      position != oldDelegate.position ||
      deform != oldDelegate.deform ||
      activeColor != oldDelegate.activeColor ||
      inactiveColor != oldDelegate.inactiveColor;
}
