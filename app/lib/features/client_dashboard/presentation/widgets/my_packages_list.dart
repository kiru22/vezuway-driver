import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/package_box_icon.dart';
import '../../../packages/data/models/package_model.dart';
import '../../../packages/domain/providers/package_provider.dart';
import '../../../packages/presentation/widgets/package_card_v2.dart';

class MyPackagesList extends ConsumerWidget {
  const MyPackagesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final packagesState = ref.watch(packagesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.clientDashboard_myShipments,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/packages'),
                child: Text(l10n.clientDashboard_viewAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            if (packagesState.isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (packagesState.error != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error',
                  subtitle: packagesState.error!,
                  iconColor: AppColors.error,
                ),
              );
            }

            // Filtrar solo paquetes activos (registered, inTransit, delayed)
            final activePackages = packagesState.packages.where((pkg) {
              return pkg.status == PackageStatus.registered ||
                  pkg.status == PackageStatus.inTransit ||
                  pkg.status == PackageStatus.delayed;
            }).take(5).toList();

            if (activePackages.isEmpty) {
              return EmptyState(
                icon: Icons.inventory_2_outlined,
                iconWidget: PackageBoxIcon(
                  size: 40,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
                title: l10n.clientDashboard_noShipments,
                subtitle: l10n.clientDashboard_createFirst,
              );
            }

            return Column(
              children: activePackages.map((package) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 12,
                  ),
                  child: PackageCardV2(
                    package: package,
                    onTap: () => context.push('/packages/${package.id}'),
                    onStatusChange: (status) {},
                    isExpanded: false,
                    isSelectionMode: false,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
