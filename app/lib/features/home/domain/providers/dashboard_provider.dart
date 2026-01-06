import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../routes/data/models/route_model.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../../packages/domain/providers/package_provider.dart';

class DashboardStats {
  final RouteModel? nextTrip;
  final RouteModel? activeTrip;
  final int packagesCount;
  final double totalWeight;
  final double totalDeclaredValue;
  final int totalTripsCount;
  final int completedTripsCount;

  const DashboardStats({
    this.nextTrip,
    this.activeTrip,
    this.packagesCount = 0,
    this.totalWeight = 0,
    this.totalDeclaredValue = 0,
    this.totalTripsCount = 0,
    this.completedTripsCount = 0,
  });

  factory DashboardStats.empty() => const DashboardStats();
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  // Watch routes state
  final routesState = ref.watch(routesProvider);
  final packagesState = ref.watch(packagesProvider);

  // Get all routes
  final routes = routesState.routes;

  // Find next planned trip (upcoming) - considers all schedule dates
  final plannedRoutes = routes
      .where((r) => r.status == RouteStatus.planned && r.hasUpcomingDates)
      .toList()
    ..sort((a, b) => (a.nextDepartureDate ?? a.departureDate)
        .compareTo(b.nextDepartureDate ?? b.departureDate));

  final nextTrip = plannedRoutes.isNotEmpty ? plannedRoutes.first : null;

  // Find active trip (in progress)
  final activeRoutes = routes.where((r) => r.status == RouteStatus.inProgress).toList();
  final activeTrip = activeRoutes.isNotEmpty ? activeRoutes.first : null;

  // Get current trip (active or next)
  final currentTrip = activeTrip ?? nextTrip;

  // Calculate packages stats for current trip
  int packagesCount = 0;
  double totalWeight = 0;
  double totalDeclaredValue = 0;

  if (currentTrip != null) {
    // Filter packages by route
    final packages = packagesState.packages
        .where((p) => p.routeId == currentTrip.id)
        .toList();

    packagesCount = packages.length;
    totalWeight = packages.fold(0, (sum, p) => sum + (p.weight ?? 0));
    totalDeclaredValue = packages.fold(0, (sum, p) => sum + (p.declaredValue ?? 0));
  }

  // Count trips
  final totalTripsCount = routes.length;
  final completedTripsCount = routes.where((r) => r.status == RouteStatus.completed).length;

  return DashboardStats(
    nextTrip: nextTrip,
    activeTrip: activeTrip,
    packagesCount: packagesCount,
    totalWeight: totalWeight,
    totalDeclaredValue: totalDeclaredValue,
    totalTripsCount: totalTripsCount,
    completedTripsCount: completedTripsCount,
  );
});

final upcomingTripsProvider = Provider<List<RouteModel>>((ref) {
  final routesState = ref.watch(routesProvider);

  // Get planned routes with upcoming dates and in-progress routes
  return routesState.routes
      .where((r) =>
          (r.status == RouteStatus.planned && r.hasUpcomingDates) ||
          r.status == RouteStatus.inProgress)
      .toList()
    ..sort((a, b) {
      // Active trips first, then by next departure date
      if (a.status == RouteStatus.inProgress && b.status != RouteStatus.inProgress) {
        return -1;
      }
      if (b.status == RouteStatus.inProgress && a.status != RouteStatus.inProgress) {
        return 1;
      }
      return (a.nextDepartureDate ?? a.departureDate)
          .compareTo(b.nextDepartureDate ?? b.departureDate);
    });
});
