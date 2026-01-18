import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// A reusable shimmer effect widget for loading states.
///
/// Wraps any child widget with an animated shimmer gradient effect.
/// The shimmer animates horizontally from left to right in a loop.
class ShimmerWidget extends StatefulWidget {
  /// The child widget to apply the shimmer effect to.
  /// If null, renders a simple white container that receives the shimmer.
  final Widget? child;

  /// Duration of one complete shimmer animation cycle.
  final Duration duration;

  /// Border radius for the default container when no child is provided.
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    super.key,
    this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.borderRadius,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colors.shimmerBase,
                colors.shimmerHighlight,
                colors.shimmerBase,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.child ??
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: widget.borderRadius,
                ),
              ),
        );
      },
    );
  }
}
