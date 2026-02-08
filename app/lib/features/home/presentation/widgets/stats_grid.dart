import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/gradient_kpi_bar.dart';
import '../../../../shared/widgets/package_box_icon.dart';
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

    return GradientKpiBar(
      items: [
        KpiItem(
          icon: Icons.inventory_2_rounded,
          iconWidget:
              const PackageBoxIcon(size: 56, color: Colors.white, filled: true),
          label: l10n.stats_packages,
          value: NumberFormat('#,##0', 'es').format(stats.packagesCount),
        ),
        KpiItem(
          icon: Icons.people_rounded,
          label: l10n.stats_contacts,
          value: NumberFormat('#,##0', 'es').format(stats.contactsCount),
        ),
        KpiItem(
          icon: Icons.euro_rounded,
          label: l10n.stats_declaredValue,
          value:
              '${NumberFormat('#,##0', 'es').format(stats.totalDeclaredValue.toInt())}\u20AC',
        ),
      ],
    );
  }
}
