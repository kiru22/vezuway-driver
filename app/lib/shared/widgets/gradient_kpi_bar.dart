import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class KpiItem {
  final IconData icon;
  final Widget? iconWidget;
  final String value;
  final String label;

  const KpiItem({
    required this.icon,
    this.iconWidget,
    required this.value,
    required this.label,
  });
}

class GradientKpiBar extends StatelessWidget {
  final List<KpiItem> items;

  const GradientKpiBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D9488), const Color(0xFF059669)]
              : [const Color(0xFF10B981), const Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                  indent: 12,
                  endIndent: 12,
                ),
              Expanded(child: _buildKpi(items[i])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKpi(KpiItem item) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 2,
          bottom: 2,
          child: Opacity(
            opacity: 0.12,
            child: item.iconWidget ??
                Icon(item.icon, size: 56, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
