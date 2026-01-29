import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../../shared/widgets/pill_tab_bar.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../domain/providers/trip_provider.dart';
import '../widgets/trips_tab.dart';
import '../widgets/routes_tab.dart';

/// Provider para el índice del tab activo en TripsRoutesScreen
/// 0 = Viajes, 1 = Rutas
final tripsRoutesTabIndexProvider = StateProvider<int>((ref) => 0);

class TripsRoutesScreen extends ConsumerStatefulWidget {
  const TripsRoutesScreen({super.key});

  @override
  ConsumerState<TripsRoutesScreen> createState() => _TripsRoutesScreenState();
}

class _TripsRoutesScreenState extends ConsumerState<TripsRoutesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tripsProvider.notifier).loadTrips();
      ref.read(routesProvider.notifier).loadRoutes();
    });
  }

  void _onTabChanged() {
    // Actualizar siempre que cambie el index
    ref.read(tripsRoutesTabIndexProvider.notifier).state = _tabController.index;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          AppHeader(
            title: l10n.tripsRoutes_title,
            showMenu: false,
          ),
          // Tab bar
          PillTabBar(
            controller: _tabController,
            labels: [l10n.tripsRoutes_trips, l10n.tripsRoutes_routes],
            onTap: (index) {
              ref.read(tripsRoutesTabIndexProvider.notifier).state = index;
            },
          ),
          const SizedBox(height: 16),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TripsTab(
                  onCreateTrip: () => context.push('/trips/create'),
                  onStatusChange: _handleTripStatusChange,
                  onDelete: _handleTripDelete,
                ),
                RoutesTab(
                  onCreateRoute: () => context.push('/routes/create'),
                  onEdit: (routeId) => context.push('/routes/$routeId/edit'),
                  onDelete: _handleRouteDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTripStatusChange(String tripId, dynamic newStatus) {
    ref.read(tripsProvider.notifier).updateStatus(tripId, newStatus);
  }

  Future<void> _handleTripDelete(String tripId) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      itemType: 'viaje',
    );
    if (confirmed == true && mounted) {
      final success = await ref.read(tripsProvider.notifier).deleteTrip(tripId);
      if (mounted) {
        _showSnackBar(
          success ? 'Viaje eliminado' : 'Error al eliminar viaje',
          success,
        );
      }
    }
  }

  Future<void> _handleRouteDelete(String routeId) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      itemType: 'plantilla de ruta',
    );
    if (confirmed == true && mounted) {
      final success =
          await ref.read(routesProvider.notifier).deleteRoute(routeId);
      if (mounted) {
        _showSnackBar(
          success ? 'Plantilla eliminada' : 'Error al eliminar plantilla',
          success,
        );
      }
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}
