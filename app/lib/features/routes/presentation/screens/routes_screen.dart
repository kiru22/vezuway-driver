import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
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

    // Group routes by status
    final activeRoutes = routesState.routes
        .where((r) => r.status == RouteStatus.inProgress)
        .toList();
    final plannedRoutes = routesState.routes
        .where((r) => r.status == RouteStatus.planned)
        .toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
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
            title: 'Rutas',
            showLanguageSelector: false,
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
                Tab(text: 'Activas (${activeRoutes.length})'),
                Tab(text: 'Próximas (${plannedRoutes.length})'),
                Tab(text: 'Historial'),
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
                  emptyMessage: 'No hay rutas activas',
                  emptySubtitle: 'Las rutas en progreso aparecerán aquí',
                  onRefresh: () =>
                      ref.read(routesProvider.notifier).loadRoutes(),
                  onStatusChange: _handleStatusChange,
                ),
                _RoutesTabContent(
                  routes: plannedRoutes,
                  isLoading: routesState.isLoading,
                  error: routesState.error,
                  emptyMessage: 'No hay rutas programadas',
                  emptySubtitle: 'Crea una nueva ruta para empezar',
                  onRefresh: () =>
                      ref.read(routesProvider.notifier).loadRoutes(),
                  onStatusChange: _handleStatusChange,
                ),
                _RoutesTabContent(
                  routes: completedRoutes,
                  isLoading: routesState.isLoading,
                  error: routesState.error,
                  emptyMessage: 'Sin historial',
                  emptySubtitle: 'Las rutas completadas aparecerán aquí',
                  onRefresh: () =>
                      ref.read(routesProvider.notifier).loadRoutes(),
                  onStatusChange: _handleStatusChange,
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
}

class _RoutesTabContent extends StatelessWidget {
  final List<RouteModel> routes;
  final bool isLoading;
  final String? error;
  final String emptyMessage;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final void Function(RouteModel, RouteStatus) onStatusChange;

  const _RoutesTabContent({
    required this.routes,
    required this.isLoading,
    this.error,
    required this.emptyMessage,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.onStatusChange,
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
              child: const Text('Reintentar'),
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
          );
        },
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteModel route;
  final void Function(RouteStatus) onStatusChange;

  const _RouteCard({
    required this.route,
    required this.onStatusChange,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              StatusChip(
                label: route.status.displayName.toUpperCase(),
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
          Row(
            children: [
              // Packages count
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: '${route.packagesCount} paquetes',
              ),
              const Spacer(),
              // Actions menu
              if (route.status != RouteStatus.completed &&
                  route.status != RouteStatus.cancelled)
                PopupMenuButton<RouteStatus>(
                  icon: Icon(Icons.more_vert, color: colors.textMuted),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: onStatusChange,
                  itemBuilder: (context) => RouteStatus.values
                      .where((s) => s != route.status)
                      .map((status) => PopupMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(status.displayName),
                              ],
                            ),
                          ))
                      .toList(),
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
