import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';
import 'gooey_base.dart';

enum BadgeStyle { warning, success, neutral }

class GooeyTabBar extends StatefulWidget {
  const GooeyTabBar({
    super.key,
    required this.labels,
    required this.controller,
    this.badges,
    this.badgeStyles,
    this.width,
    this.height = 52.0,
    this.trackColor,
    this.thumbColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.enabled = true,
  });

  final List<String> labels;
  final TabController controller;
  final List<int?>? badges;
  final List<BadgeStyle?>? badgeStyles;
  final double? width;
  final double height;
  final Color? trackColor;
  final Color? thumbColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final bool enabled;

  @override
  State<GooeyTabBar> createState() => _GooeyTabBarState();
}

class _GooeyTabBarState extends State<GooeyTabBar>
    with TickerProviderStateMixin {
  static const _thumbPadding = 3.0;

  late final AnimationController _positionController;
  late final AnimationController _deformController;

  double _dragStartX = 0;
  bool _dragging = false;

  int get _tabCount => widget.labels.length;

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController.unbounded(
      vsync: this,
      value: widget.controller.index.toDouble(),
    );
    _deformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    widget.controller.animation?.addListener(_onTabAnimation);
  }

  @override
  void didUpdateWidget(covariant GooeyTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.animation?.removeListener(_onTabAnimation);
      widget.controller.animation?.addListener(_onTabAnimation);
      _animateTo(widget.controller.index);
    }
  }

  void _onTabAnimation() {
    if (_dragging) return;
    final tabAnim = widget.controller.animation;
    if (tabAnim != null) {
      _positionController.value = tabAnim.value;
    }
  }

  void _animateTo(int index) {
    final spring = SpringDescription(mass: 1.6, stiffness: 120, damping: 14);
    final simulation = SpringSimulation(
      spring,
      _positionController.value,
      index.toDouble(),
      0,
    );
    _positionController.animateWith(simulation);
    _deformController.forward(from: 0);
  }

  void _handleTap(double localX, double trackWidth) {
    if (!widget.enabled) return;
    final segmentWidth = trackWidth / _tabCount;
    final tapped = (localX / segmentWidth).floor().clamp(0, _tabCount - 1);
    if (tapped != widget.controller.index) {
      widget.controller.animateTo(tapped);
      _animateTo(tapped);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _dragging = true;
    _dragStartX = details.localPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (!_dragging) return;
    final dx = details.localPosition.dx - _dragStartX;
    final segmentWidth = trackWidth / _tabCount;
    final delta = dx / segmentWidth;
    _positionController.value = (_positionController.value + delta)
        .clamp(0.0, (_tabCount - 1).toDouble());
    _dragStartX = details.localPosition.dx;

    final velocityFraction =
        (details.delta.dx.abs() / trackWidth).clamp(0.0, 1.0);
    if (velocityFraction > 0.01) {
      _deformController.value =
          (_deformController.value + velocityFraction * 2).clamp(0.0, 1.0);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    final snapped = _positionController.value.round().clamp(0, _tabCount - 1);
    if (snapped != widget.controller.index) {
      widget.controller.animateTo(snapped);
    }
    _animateTo(snapped);
  }

  double _deformCurve(double t) => math.sin(t * math.pi);

  @override
  void dispose() {
    widget.controller.animation?.removeListener(_onTabAnimation);
    _positionController.dispose();
    _deformController.dispose();
    super.dispose();
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = widget.width ?? constraints.maxWidth;

          return GestureDetector(
            onTapUp: (d) => _handleTap(d.localPosition.dx, trackWidth),
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: (d) => _handleDragUpdate(d, trackWidth),
            onHorizontalDragEnd: _handleDragEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [_positionController, _deformController]),
              builder: (context, _) {
                final position = _positionController.value;
                final deform = _deformCurve(_deformController.value);

                return SizedBox(
                  width: trackWidth,
                  height: widget.height,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(trackWidth, widget.height),
                        painter: _GooeyTabBarPainter(
                          position: position,
                          tabCount: _tabCount,
                          deform: deform,
                          trackColor: trackColor,
                          thumbColor: thumbColor,
                          padding: _thumbPadding,
                        ),
                      ),
                      Row(
                        children: List.generate(_tabCount, (i) {
                          final distance =
                              (position - i).abs().clamp(0.0, 1.0);
                          final proximity = 1.0 - distance;

                          final color = Color.lerp(
                            unselectedTextColor,
                            selectedTextColor,
                            proximity,
                          )!;
                          final weight = FontWeight.lerp(
                            FontWeight.w500,
                            FontWeight.w700,
                            proximity,
                          )!;

                          final badgeCount = widget.badges != null &&
                                  i < widget.badges!.length
                              ? widget.badges![i]
                              : null;
                          final showBadge =
                              badgeCount != null && badgeCount > 0;

                          return Expanded(
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.labels[i],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: weight,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  if (showBadge) ...[
                                    const SizedBox(width: 6),
                                    _buildBadge(
                                      context,
                                      badgeCount,
                                      (widget.badgeStyles != null &&
                                              i <
                                                  widget
                                                      .badgeStyles!.length
                                          ? widget.badgeStyles![i]
                                          : null) ??
                                          BadgeStyle.neutral,
                                      proximity,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(
      BuildContext context, int count, BadgeStyle style, double proximity) {
    final colors = context.colors;

    final (bgColor, textColor) = switch (style) {
      BadgeStyle.warning => (
          AppColors.statusWarningBg,
          AppColors.statusWarningText,
        ),
      BadgeStyle.success => (
          AppColors.statusSuccessBg,
          AppColors.statusSuccessText,
        ),
      BadgeStyle.neutral => (
          colors.border.withValues(alpha: 0.5),
          colors.textMuted,
        ),
    };

    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Color.lerp(bgColor, Colors.white.withValues(alpha: 0.25), proximity),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayCount,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color.lerp(textColor, Colors.white, proximity),
        ),
      ),
    );
  }
}

class _GooeyTabBarPainter extends CustomPainter {
  _GooeyTabBarPainter({
    required this.position,
    required this.tabCount,
    required this.deform,
    required this.trackColor,
    required this.thumbColor,
    required this.padding,
  });

  final double position;
  final int tabCount;
  final double deform;
  final Color trackColor;
  final Color thumbColor;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRadius = size.height / 2;
    final segmentWidth = size.width / tabCount;
    final thumbWidth = segmentWidth - (padding * 2);
    final thumbHeight = size.height - (padding * 2);
    final thumbRadius = thumbHeight / 2;

    final thumbX = padding + position * segmentWidth;
    final thumbY = padding;

    final stretchFactor =
        1.0 + (GooeyBaseState.stretchX - 1.0) * deform * 0.7;
    final squishFactor =
        1.0 - (1.0 - GooeyBaseState.squishY) * deform * 0.5;

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
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GooeyTabBarPainter oldDelegate) =>
      position != oldDelegate.position ||
      deform != oldDelegate.deform ||
      tabCount != oldDelegate.tabCount ||
      trackColor != oldDelegate.trackColor ||
      thumbColor != oldDelegate.thumbColor;
}
