import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';
import 'gooey_base.dart';

class GooeyToggle extends GooeyBaseWidget {
  const GooeyToggle({
    super.key,
    required super.value,
    required super.onChanged,
    required this.leftLabel,
    required this.rightLabel,
    this.width,
    this.height,
    this.trackColor,
    this.thumbColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    super.enabled,
  });

  final String leftLabel;
  final String rightLabel;
  final double? width;
  final double? height;
  final Color? trackColor;
  final Color? thumbColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  @override
  State<GooeyToggle> createState() => _GooeyToggleState();
}

class _GooeyToggleState extends GooeyBaseState<GooeyToggle> {
  static const _defaultWidth = 110.0;
  static const _defaultHeight = 38.0;
  static const _thumbPadding = 3.0;

  double get _width => widget.width ?? _defaultWidth;
  double get _height => widget.height ?? _defaultHeight;

  @override
  double get trackWidth => _width;

  @override
  double get trackHeight => _height;

  @override
  void animateTo(bool on) {
    final target = on ? 1.0 : 0.0;
    final spring = SpringDescription(mass: 1.6, stiffness: 120, damping: 14);
    final simulation = SpringSimulation(
      spring,
      positionController.value,
      target,
      0,
    );
    positionController.animateWith(simulation);
    deformController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = widget.trackColor ??
        (isDark
            ? Color.lerp(colors.background, colors.surface, 0.25)!
            : colors.surfaceLight);
    final thumbColor = widget.thumbColor ?? AppColors.primary;
    final selectedTextColor = widget.selectedTextColor ?? Colors.white;
    final unselectedTextColor =
        widget.unselectedTextColor ?? colors.textSecondary;

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
            final position = positionController.value;
            final deform = deformCurve(deformController.value);

            return SizedBox(
              width: _width,
              height: _height,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(_width, _height),
                    painter: _GooeyTogglePainter(
                      position: position,
                      deform: deform,
                      trackColor: trackColor,
                      thumbColor: thumbColor,
                      padding: _thumbPadding,
                      showThumbGlow: isDark,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.leftLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: position < 0.5
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: Color.lerp(
                                selectedTextColor,
                                unselectedTextColor,
                                position,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.rightLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: position >= 0.5
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: Color.lerp(
                                unselectedTextColor,
                                selectedTextColor,
                                position,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GooeyTogglePainter extends CustomPainter {
  _GooeyTogglePainter({
    required this.position,
    required this.deform,
    required this.trackColor,
    required this.thumbColor,
    required this.padding,
    this.showThumbGlow = false,
  });

  final double position;
  final double deform;
  final Color trackColor;
  final Color thumbColor;
  final double padding;
  final bool showThumbGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRadius = size.height / 2;
    final thumbWidth = (size.width / 2) - padding;
    final thumbHeight = size.height - (padding * 2);
    final thumbRadius = thumbHeight / 2;

    final minX = padding;
    final maxX = size.width / 2;
    final thumbX = minX + (maxX - minX) * position;
    final thumbY = padding;

    final stretchFactor = 1.0 + (GooeyBaseState.stretchX - 1.0) * deform * 0.7;
    final squishFactor = 1.0 - (1.0 - GooeyBaseState.squishY) * deform * 0.5;

    final trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(trackRadius),
    );
    canvas.save();
    canvas.clipRRect(trackRRect);

    final blurSigma = size.height * 0.3;
    final layerPaint = Paint()
      ..imageFilter = ui.ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
      );

    canvas.saveLayer(Offset.zero & size, layerPaint);

    final trackPaint = Paint()..color = trackColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(trackRadius),
      ),
      trackPaint,
    );

    final thumbPaint = Paint()..color = thumbColor;
    final thumbCx = thumbX + thumbWidth / 2;
    final thumbCy = thumbY + thumbHeight / 2;
    canvas.save();
    canvas.translate(thumbCx, thumbCy);
    canvas.scale(stretchFactor, squishFactor);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: thumbWidth,
          height: thumbHeight,
        ),
        Radius.circular(thumbRadius),
      ),
      thumbPaint,
    );
    canvas.restore();
    canvas.restore();
    canvas.restore();

    final crispTrackPaint = Paint()..color = trackColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        Radius.circular(trackRadius - 1),
      ),
      crispTrackPaint,
    );

    final crispThumbPaint = Paint()..color = thumbColor;
    final crispW = thumbWidth * 0.92;
    final crispH = thumbHeight * 0.88;
    final crispR = crispH / 2;
    canvas.save();
    canvas.translate(thumbCx, thumbCy);
    canvas.scale(stretchFactor, squishFactor);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: crispW, height: crispH),
        Radius.circular(crispR),
      ),
      crispThumbPaint,
    );

    if (showThumbGlow) {
      final glowPaint = Paint()
        ..color = thumbColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: crispW + 1, height: crispH + 1),
          Radius.circular(crispR),
        ),
        glowPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GooeyTogglePainter oldDelegate) =>
      position != oldDelegate.position ||
      deform != oldDelegate.deform ||
      trackColor != oldDelegate.trackColor ||
      thumbColor != oldDelegate.thumbColor ||
      showThumbGlow != oldDelegate.showThumbGlow;
}
