import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/package_box_icon.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../data/models/client_stats_model.dart';

class ClientStatsGrid extends ConsumerWidget {
  final ClientStats stats;

  const ClientStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stats.total == 0) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.inventory_2_rounded,
            iconWidget: const PackageBoxIcon(size: 48, color: Colors.white, filled: true),
            label: l10n.clientDashboard_totalShipments,
            value: '${stats.total}',
            gradient: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.local_shipping_rounded,
            label: l10n.clientDashboard_inTransit,
            value: '${stats.inTransit}',
            gradient: [AppColors.warning, const Color(0xFFD97706)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.check_circle_rounded,
            label: l10n.clientDashboard_delivered,
            value: '${stats.delivered}',
            gradient: [AppColors.success, const Color(0xFF16A34A)],
          ),
        ),
      ],
    );
  }
}
