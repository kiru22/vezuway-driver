import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

abstract class GooeyBaseWidget extends StatefulWidget {
  const GooeyBaseWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
}

abstract class GooeyBaseState<T extends GooeyBaseWidget> extends State<T>
    with TickerProviderStateMixin {
  static const stretchX = 1.4;
  static const squishY = 0.6;

  late final AnimationController positionController;
  late final AnimationController deformController;

  double _dragStartX = 0;
  bool _dragging = false;

  double get trackWidth;
  double get trackHeight;

  @override
  void initState() {
    super.initState();
    positionController = AnimationController(
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
    deformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      animateTo(widget.value);
    }
  }

  void animateTo(bool on) {
    final target = on ? 1.0 : 0.0;
    final spring = SpringDescription(mass: 1, stiffness: 180, damping: 12);
    final simulation = SpringSimulation(
      spring,
      positionController.value,
      target,
      0,
    );
    positionController.animateWith(simulation);
    deformController.forward(from: 0);
  }

  void handleTap() {
    if (!widget.enabled) return;
    widget.onChanged(!widget.value);
  }

  void handleDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _dragging = true;
    _dragStartX = details.localPosition.dx;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    final dx = details.localPosition.dx - _dragStartX;
    final delta = dx / (trackWidth * 0.5);
    positionController.value =
        (positionController.value + delta).clamp(0.0, 1.0);
    _dragStartX = details.localPosition.dx;

    final velocityFraction =
        (details.delta.dx.abs() / trackWidth).clamp(0.0, 1.0);
    if (velocityFraction > 0.01) {
      deformController.value =
          (deformController.value + velocityFraction * 2).clamp(0.0, 1.0);
    }
  }

  void handleDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    final snapped = positionController.value >= 0.5;
    if (snapped != widget.value) {
      widget.onChanged(snapped);
    } else {
      animateTo(widget.value);
    }
  }

  double deformCurve(double t) => math.sin(t * math.pi);

  @override
  void dispose() {
    positionController.dispose();
    deformController.dispose();
    super.dispose();
  }
}
