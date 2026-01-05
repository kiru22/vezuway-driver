import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.dotSize = 8,
    this.activeDotWidth = 24,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isActive ? activeDotWidth : dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : colors.border,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
