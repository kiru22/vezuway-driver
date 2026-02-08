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
  final int contactsCount;

  const DashboardStats({
    this.nextTrip,
    this.activeTrip,
    this.packagesCount = 0,
    this.totalWeight = 0,
    this.totalDeclaredValue = 0,
    this.totalTripsCount = 0,
    this.completedTripsCount = 0,
    this.contactsCount = 0,
  });

  factory DashboardStats.empty() => const DashboardStats();
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final tripsState = ref.watch(tripsProvider);
  final repository = ref.read(packageRepositoryProvider);
  final allPackages = await repository.getPackages();

  final trips = tripsState.trips;

  final plannedTrips = trips
      .where((t) => t.status == TripStatus.planned)
      .toList()
    ..sort((a, b) => a.departureDate.compareTo(b.departureDate));

  final nextTrip = plannedTrips.isNotEmpty ? plannedTrips.first : null;

  final activeTrips =
      trips.where((t) => t.status == TripStatus.inProgress).toList();
  final activeTrip = activeTrips.isNotEmpty ? activeTrips.first : null;

  final packagesCount = allPackages.length;
  final totalWeight =
      allPackages.fold<double>(0, (sum, p) => sum + (p.weight ?? 0));
  final totalDeclaredValue =
      allPackages.fold<double>(0, (sum, p) => sum + (p.declaredValue ?? 0));

  final uniqueContacts = <String>{};
  for (final p in allPackages) {
    if (p.senderContactId != null) uniqueContacts.add(p.senderContactId!);
    if (p.receiverContactId != null) uniqueContacts.add(p.receiverContactId!);
  }
  final contactsCount = uniqueContacts.length;

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
    contactsCount: contactsCount,
  );
});

final upcomingTripsProvider = Provider<List<TripModel>>((ref) {
  final tripsState = ref.watch(tripsProvider);

  return tripsState.trips
      .where((t) =>
          t.status == TripStatus.planned || t.status == TripStatus.inProgress)
      .toList()
    ..sort((a, b) {
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
