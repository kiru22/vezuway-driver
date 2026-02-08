import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/package_box_icon.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../domain/providers/dashboard_provider.dart';

class StatsGrid extends ConsumerWidget {
  final DashboardStats stats;

  const StatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (stats.packagesCount == 0) {
      return const SizedBox.shrink();
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.inventory_2_rounded,
              iconWidget: const PackageBoxIcon(
                  size: 20, color: Colors.white, filled: true),
              label: l10n.stats_packages,
              value: NumberFormat('#,##0', 'es').format(stats.packagesCount),
              gradient: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.scale_rounded,
              label: l10n.stats_totalWeight,
              value:
                  '${NumberFormat('#,##0.0', 'es').format(stats.totalWeight)} ${l10n.common_kg}',
              gradient: [AppColors.warning, const Color(0xFFD97706)],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.euro_rounded,
              label: l10n.stats_declaredValue,
              value:
                  '${NumberFormat('#,##0', 'es').format(stats.totalDeclaredValue.toInt())}\u20AC',
              gradient: [AppColors.success, const Color(0xFF16A34A)],
            ),
          ),
        ],
      ),
    );
  }
}
