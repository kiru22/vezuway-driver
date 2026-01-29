import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';

/// Badge style for PillTabBar badges
enum BadgeStyle {
  /// Orange/warning style - for alerts and pending items
  warning,

  /// Green/success style - for positive counts
  success,

  /// Gray/neutral style - for informational counts
  neutral,
}

/// A pill-style tab bar with rounded indicator and subtle shadow.
/// Consistent styling across the app for section switches.
class PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  final ValueChanged<int>? onTap;

  /// Optional badge counts for each tab. Null or 0 means no badge shown.
  final List<int?>? badges;

  /// Optional badge styles for each tab. Defaults to neutral.
  final List<BadgeStyle?>? badgeStyles;

  const PillTabBar({
    super.key,
    required this.controller,
    required this.labels,
    this.onTap,
    this.badges,
    this.badgeStyles,
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
        isScrollable: labels.length > 2,
        tabAlignment: labels.length > 2 ? TabAlignment.center : TabAlignment.fill,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: colors.textMuted,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: _buildTabs(context),
      ),
    );
  }

  List<Tab> _buildTabs(BuildContext context) {
    return List.generate(labels.length, (i) {
      final label = labels[i];
      final badgeCount = badges != null && i < badges!.length ? badges![i] : null;
      final showBadge = badgeCount != null && badgeCount > 0;

      if (!showBadge) {
        return Tab(text: label);
      }

      final style = (badgeStyles != null && i < badgeStyles!.length
          ? badgeStyles![i]
          : null) ?? BadgeStyle.neutral;

      return Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            _buildBadge(context, badgeCount, style),
          ],
        ),
      );
    });
  }

  Widget _buildBadge(BuildContext context, int count, BadgeStyle style) {
    final colors = context.colors;

    // Design system colors
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
          colors.border.withValues(alpha: 0.5), // Subtle gray background
          colors.textMuted, // Muted text
        ),
    };

    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayCount,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
