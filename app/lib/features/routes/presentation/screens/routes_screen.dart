import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/models/route_model.dart';
import '../../domain/providers/route_provider.dart';
import '../widgets/route_dates_carousel.dart';

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routesProvider.notifier).loadRoutes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final routesState = ref.watch(routesProvider);

    // Group routes by date (not by status)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Active: departure date is today or in the past, but not completed/cancelled
    final activeRoutes = routesState.routes
        .where((r) =>
            r.status != RouteStatus.completed &&
            r.status != RouteStatus.cancelled &&
            !r.departureDate.isAfter(today))
        .toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));

    // Upcoming: departure date is in the future, not completed/cancelled
    final plannedRoutes = routesState.routes
        .where((r) =>
            r.status != RouteStatus.completed &&
            r.status != RouteStatus.cancelled &&
            r.departureDate.isAfter(today))
        .toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));

    // History: completed or cancelled routes
    final completedRoutes = routesState.routes
        .where((r) =>
            r.status == RouteStatus.completed ||
            r.status == RouteStatus.cancelled)
        .toList()
      ..sort((a, b) => b.departureDate.compareTo(a.departureDate));

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: [
          // Header
          AppHeader(
            title: context.l10n.routes_title,
            showMenu: false,
          ),
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
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
              tabs: [
                Tab(text: context.l10n.routes_activeTab(activeRoutes.length)),
                Tab(text: context.l10n.routes_upcomingTab(plannedRoutes.length)),
                Tab(text: context.l10n.routes_historyTab),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RoutesTabContent(
                  routes: activeRoutes,
                  isLoading: routesState.isLoading,
                  error: routesState.error,
                  emptyMessage: context.l10n.routes_emptyActive,
                  emptySubtitle: context.l10n.routes_emptyActiveSubtitle,
                  onRefresh: () =>
                      ref.read(routesProvider.notifier).loadRoutes(),
                  onStatusChange: _handleStatusChange,
                  onDelete: _handleDelete,
                ),
                _RoutesTabContent(
                  routes: plannedRoutes,
                  isLoading: routesState.isLoading,
                  error: routesState.error,
                  emptyMessage: context.l10n.routes_emptyPlanned,
                  emptySubtitle: context.l10n.routes_emptyPlannedSubtitle,
                  onRefresh: () =>
                      ref.read(routesProvider.notifier).loadRoutes(),
                  onStatusChange: _handleStatusChange,
                  onDelete: _handleDelete,
                ),
                _RoutesTabContent(
                  routes: completedRoutes,
                  isLoading: routesState.isLoading,
                  error: routesState.error,
                  emptyMessage: context.l10n.routes_emptyHistory,
                  emptySubtitle: context.l10n.routes_emptyHistorySubtitle,
                  onRefresh: () =>
                      ref.read(routesProvider.notifier).loadRoutes(),
                  onStatusChange: _handleStatusChange,
                  onDelete: _handleDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusChange(RouteModel route, RouteStatus newStatus) {
    ref.read(routesProvider.notifier).updateStatus(route.id, newStatus);
  }

  Future<void> _handleDelete(RouteModel route) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.routes_deleteConfirmTitle),
        content: Text(l10n.routes_deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(routesProvider.notifier).deleteRoute(route.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.routes_deleteSuccess : l10n.routes_deleteError,
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }
}

class _RoutesTabContent extends StatelessWidget {
  final List<RouteModel> routes;
  final bool isLoading;
  final String? error;
  final String emptyMessage;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final void Function(RouteModel, RouteStatus) onStatusChange;
  final Future<void> Function(RouteModel) onDelete;

  const _RoutesTabContent({
    required this.routes,
    required this.isLoading,
    this.error,
    required this.emptyMessage,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(error!, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: Text(context.l10n.common_retry),
            ),
          ],
        ),
      );
    }

    if (routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.route_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emptySubtitle,
              style: TextStyle(
                fontSize: 14,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return _RouteCard(
            route: route,
            onStatusChange: (status) => onStatusChange(route, status),
            onDelete: () => onDelete(route),
          );
        },
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteModel route;
  final void Function(RouteStatus) onStatusChange;
  final VoidCallback onDelete;

  const _RouteCard({
    required this.route,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  route.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: route.status.localizedName(context).toUpperCase(),
                variant: _getStatusVariant(route.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Origin - Destination
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trip_origin,
                  size: 16,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  route.origin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              width: 2,
              height: 16,
              color: colors.border,
            ),
          ),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  route.destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dates carousel
          RouteDatesCarousel(dates: route.allDepartureDates),
          const SizedBox(height: 12),
          // Info row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Packages count
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: context.l10n.packages_count(route.packagesCount),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Change status button
                  _ActionButton(
                    icon: Icons.sync_alt_rounded,
                    label: context.l10n.packages_changeStatus,
                    onTap: () => _showStatusChangeSheet(context),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: context.l10n.common_delete,
                    isDestructive: true,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  ChipVariant _getStatusVariant(RouteStatus status) {
    switch (status) {
      case RouteStatus.planned:
        return ChipVariant.blue;
      case RouteStatus.inProgress:
        return ChipVariant.orange;
      case RouteStatus.completed:
        return ChipVariant.green;
      case RouteStatus.cancelled:
        return ChipVariant.gray;
    }
  }

  Color _getStatusColor(RouteStatus status) {
    switch (status) {
      case RouteStatus.planned:
        return AppColors.primary;
      case RouteStatus.inProgress:
        return AppColors.warning;
      case RouteStatus.completed:
        return AppColors.success;
      case RouteStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  void _showStatusChangeSheet(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.packages_selectNewStatus,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...RouteStatus.values
                .where((s) => s != route.status)
                .map((status) => _StatusOption(
                      status: status,
                      color: _getStatusColor(status),
                      onTap: () {
                        Navigator.pop(context);
                        onStatusChange(status);
                      },
                    )),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final RouteStatus status;
  final Color color;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              status.localizedName(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
