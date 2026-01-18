import 'package:flutter/material.dart';

/// Helper class to create staggered animations for lists of items.
///
/// Creates synchronized fade and slide animations that start with
/// a delay between each item, creating a cascading effect.
///
/// Usage:
/// ```dart
/// late StaggeredAnimations _animations;
///
/// @override
/// void initState() {
///   super.initState();
///   _animationController = AnimationController(
///     vsync: this,
///     duration: const Duration(milliseconds: 800),
///   );
///   _animations = StaggeredAnimations(
///     controller: _animationController,
///     itemCount: 4,
///   );
///   _animationController.forward();
/// }
///
/// // In build:
/// FadeTransition(
///   opacity: _animations.fadeAnimations[0],
///   child: SlideTransition(
///     position: _animations.slideAnimations[0],
///     child: MyCard(),
///   ),
/// )
/// ```
class StaggeredAnimations {
  /// The animation controller that drives all animations.
  final AnimationController controller;

  /// Number of items to animate.
  final int itemCount;

  /// Delay between each item's animation start (0.0 to 1.0 of total duration).
  final double staggerDelay;

  /// Duration of each item's animation (0.0 to 1.0 of total duration).
  final double itemDuration;

  /// Curve applied to animations.
  final Curve curve;

  /// Starting offset for slide animations.
  final Offset slideOffset;

  /// Fade animations for each item (0.0 to 1.0).
  late final List<Animation<double>> fadeAnimations;

  /// Slide animations for each item.
  late final List<Animation<Offset>> slideAnimations;

  StaggeredAnimations({
    required this.controller,
    required this.itemCount,
    this.staggerDelay = 0.15,
    this.itemDuration = 0.4,
    this.curve = Curves.easeOutCubic,
    this.slideOffset = const Offset(0, 0.1),
  }) {
    fadeAnimations = _createFadeAnimations();
    slideAnimations = _createSlideAnimations();
  }

  List<Animation<double>> _createFadeAnimations() {
    return List.generate(itemCount, (index) {
      final start = index * staggerDelay;
      final end = (start + itemDuration).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: curve),
        ),
      );
    });
  }

  List<Animation<Offset>> _createSlideAnimations() {
    return List.generate(itemCount, (index) {
      final start = index * staggerDelay;
      final end = (start + itemDuration).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: slideOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: curve),
        ),
      );
    });
  }

  /// Get fade animation for item at index.
  Animation<double> fade(int index) => fadeAnimations[index];

  /// Get slide animation for item at index.
  Animation<Offset> slide(int index) => slideAnimations[index];
}

/// Widget that applies staggered fade and slide animations to its child.
class AnimatedStaggeredItem extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Widget child;

  const AnimatedStaggeredItem({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}
