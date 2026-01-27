import 'package:flutter/material.dart';

import '../../core/theme/theme_extensions.dart';

/// A pill-style tab bar with rounded indicator and subtle shadow.
/// Consistent styling across the app for section switches.
class PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  final ValueChanged<int>? onTap;

  const PillTabBar({
    super.key,
    required this.controller,
    required this.labels,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        indicator: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colors.textPrimary,
        unselectedLabelColor: colors.textMuted,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: labels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}
