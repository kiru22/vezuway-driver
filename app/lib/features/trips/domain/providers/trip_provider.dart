import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/city_model.dart';
import '../../../../shared/utils/date_utils.dart' as date_utils;
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/trip_status.dart';
import '../../data/repositories/trip_repository.dart';

// Trip Repository Provider
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(ref.read(apiServiceProvider));
});

// Trips List State
class TripsState {
  final List<TripModel> trips;
  final bool isLoading;
  final String? error;
  final DateTime? filterDate; // null = sin filtro

  const TripsState({
    this.trips = const [],
    this.isLoading = false,
    this.error,
    this.filterDate,
  });

  TripsState copyWith({
    List<TripModel>? trips,
    bool? isLoading,
    String? error,
    DateTime? filterDate,
    bool clearFilter = false,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterDate: clearFilter ? null : (filterDate ?? this.filterDate),
    );
  }

  // Helper getters for filtered trips
  List<TripModel> get activeTrips {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return trips
        .where((t) =>
            t.status != TripStatus.completed &&
            t.status != TripStatus.cancelled &&
            !t.departureDate.isAfter(today))
        .toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
  }

  List<TripModel> get upcomingTrips {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return trips
        .where((t) =>
            t.status != TripStatus.completed &&
            t.status != TripStatus.cancelled &&
            t.departureDate.isAfter(today))
        .toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
  }

  List<TripModel> get completedTrips {
    return trips
        .where((t) =>
            t.status == TripStatus.completed ||
            t.status == TripStatus.cancelled)
        .toList()
      ..sort((a, b) => b.departureDate.compareTo(a.departureDate));
  }

  // Filtered versions (when filterDate is set)
  List<TripModel> get filteredActiveTrips {
    if (filterDate == null) return activeTrips;
    return activeTrips
        .where((t) => date_utils.isSameDay(t.departureDate, filterDate!))
        .toList();
  }

  List<TripModel> get filteredUpcomingTrips {
    if (filterDate == null) return upcomingTrips;
    return upcomingTrips
        .where((t) => date_utils.isSameDay(t.departureDate, filterDate!))
        .toList();
  }

  List<TripModel> get filteredCompletedTrips {
    if (filterDate == null) return completedTrips;
    return completedTrips
        .where((t) => date_utils.isSameDay(t.departureDate, filterDate!))
        .toList();
  }

  // Get all unique departure dates for calendar
  Set<DateTime> get departureDates {
    return trips
        .map((t) => DateTime(
              t.departureDate.year,
              t.departureDate.month,
              t.departureDate.day,
            ))
        .toSet();
  }

  // Get dates that have trips with packages
  Set<DateTime> get datesWithPackages {
    return trips
        .where((t) => t.packagesCount > 0)
        .map((t) => DateTime(
              t.departureDate.year,
              t.departureDate.month,
              t.departureDate.day,
            ))
        .toSet();
  }

  // Get the next upcoming departure date (for highlighting in calendar)
  DateTime? get nextDepartureDate {
    final upcoming = upcomingTrips;
    if (upcoming.isEmpty) return null;
    return DateTime(
      upcoming.first.departureDate.year,
      upcoming.first.departureDate.month,
      upcoming.first.departureDate.day,
    );
  }
}

// Trips Notifier
class TripsNotifier extends StateNotifier<TripsState> {
  final TripRepository _repository;
  bool _isInitialized = false;

  TripsNotifier(this._repository) : super(const TripsState()) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await loadTrips();
  }

  Future<void> loadTrips({
    TripStatus? status,
    bool? upcoming,
    bool? active,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final trips = await _repository.getTrips(
        status: status,
        upcoming: upcoming,
        active: active,
      );
      state = state.copyWith(trips: trips, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar viajes',
      );
    }
  }

  Future<bool> createTrip({
    String? routeId,
    required String originCity,
    required String originCountry,
    required String destinationCity,
    required String destinationCountry,
    required DateTime departureDate,
    TimeOfDay? departureTime,
    DateTime? estimatedArrivalDate,
    String? notes,
    List<CityModel>? stops,
    double? pricePerKg,
    double? minimumPrice,
    double? priceMultiplier,
  }) async {
    try {
      final newTrip = await _repository.createTrip(
        routeId: routeId,
        originCity: originCity,
        originCountry: originCountry,
        destinationCity: destinationCity,
        destinationCountry: destinationCountry,
        departureDate: departureDate,
        departureTime: departureTime,
        estimatedArrivalDate: estimatedArrivalDate,
        notes: notes,
        stops: stops,
        pricePerKg: pricePerKg,
        minimumPrice: minimumPrice,
        priceMultiplier: priceMultiplier,
      );
      state = state.copyWith(
        trips: [newTrip, ...state.trips],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createTripFromRoute({
    required String routeId,
    required DateTime departureDate,
    TimeOfDay? departureTime,
    DateTime? estimatedArrivalDate,
    String? notes,
  }) async {
    try {
      final newTrip = await _repository.createTripFromRoute(
        routeId: routeId,
        departureDate: departureDate,
        departureTime: departureTime,
        estimatedArrivalDate: estimatedArrivalDate,
        notes: notes,
      );
      state = state.copyWith(
        trips: [newTrip, ...state.trips],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(String id, TripStatus status) async {
    try {
      final updated = await _repository.updateStatus(id, status);
      final trips = state.trips.map((t) {
        return t.id == id ? updated : t;
      }).toList();
      state = state.copyWith(trips: trips);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTrip(String id) async {
    try {
      await _repository.deleteTrip(id);
      final trips = state.trips.where((t) => t.id != id).toList();
      state = state.copyWith(trips: trips);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Filter trips by a specific date
  void filterByDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    state = state.copyWith(filterDate: normalizedDate);
  }

  /// Clear the date filter
  void clearDateFilter() {
    state = state.copyWith(clearFilter: true);
  }
}

// Trips Provider
final tripsProvider = StateNotifierProvider<TripsNotifier, TripsState>((ref) {
  return TripsNotifier(ref.read(tripRepositoryProvider));
});

// Single Trip Provider
final tripDetailProvider =
    FutureProvider.family<TripModel, String>((ref, id) async {
  final repository = ref.read(tripRepositoryProvider);
  return repository.getTrip(id);
});
