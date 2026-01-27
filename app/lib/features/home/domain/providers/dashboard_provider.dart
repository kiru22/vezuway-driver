import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../../trips/data/models/trip_status.dart';
import '../../../trips/domain/providers/trip_provider.dart';
import '../../../packages/domain/providers/package_provider.dart';

class DashboardStats {
  final TripModel? nextTrip;
  final TripModel? activeTrip;
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
  // Watch trips state
  final tripsState = ref.watch(tripsProvider);
  final packagesState = ref.watch(packagesProvider);

  // Get all trips
  final trips = tripsState.trips;

  // Find next planned trip (upcoming)
  final plannedTrips = trips
      .where((t) => t.status == TripStatus.planned)
      .toList()
    ..sort((a, b) => a.departureDate.compareTo(b.departureDate));

  final nextTrip = plannedTrips.isNotEmpty ? plannedTrips.first : null;

  // Find active trip (in progress)
  final activeTrips =
      trips.where((t) => t.status == TripStatus.inProgress).toList();
  final activeTrip = activeTrips.isNotEmpty ? activeTrips.first : null;

  // Get current trip (active or next)
  final currentTrip = activeTrip ?? nextTrip;

  // Calculate packages stats for current trip
  int packagesCount = 0;
  double totalWeight = 0;
  double totalDeclaredValue = 0;

  if (currentTrip != null) {
    // Filter packages by trip
    final packages = packagesState.packages
        .where((p) => p.tripId == currentTrip.id)
        .toList();

    packagesCount = packages.length;
    totalWeight = packages.fold(0, (sum, p) => sum + (p.weight ?? 0));
    totalDeclaredValue =
        packages.fold(0, (sum, p) => sum + (p.declaredValue ?? 0));
  }

  // Count trips
  final totalTripsCount = trips.length;
  final completedTripsCount =
      trips.where((t) => t.status == TripStatus.completed).length;

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

final upcomingTripsProvider = Provider<List<TripModel>>((ref) {
  final tripsState = ref.watch(tripsProvider);

  // Get planned and in-progress trips
  return tripsState.trips
      .where((t) =>
          t.status == TripStatus.planned || t.status == TripStatus.inProgress)
      .toList()
    ..sort((a, b) {
      // Active trips first, then by departure date
      if (a.status == TripStatus.inProgress &&
          b.status != TripStatus.inProgress) {
        return -1;
      }
      if (b.status == TripStatus.inProgress &&
          a.status != TripStatus.inProgress) {
        return 1;
      }
      return a.departureDate.compareTo(b.departureDate);
    });
});
