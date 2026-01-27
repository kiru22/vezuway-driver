import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/city_model.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/route_repository.dart';

// Route Repository Provider
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(ref.read(apiServiceProvider));
});

// Routes List State
class RoutesState {
  final List<RouteModel> routes;
  final bool isLoading;
  final String? error;

  const RoutesState({
    this.routes = const [],
    this.isLoading = false,
    this.error,
  });

  RoutesState copyWith({
    List<RouteModel>? routes,
    bool? isLoading,
    String? error,
  }) {
    return RoutesState(
      routes: routes ?? this.routes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Routes Notifier
class RoutesNotifier extends StateNotifier<RoutesState> {
  final RouteRepository _repository;
  bool _isInitialized = false;

  RoutesNotifier(this._repository) : super(const RoutesState()) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await loadRoutes();
  }

  Future<void> loadRoutes({bool? activeOnly}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final routes = await _repository.getRoutes(activeOnly: activeOnly);
      state = state.copyWith(routes: routes, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar plantillas de rutas',
      );
    }
  }

  Future<bool> createRoute({
    String? name,
    String? description,
    int? estimatedDurationHours,
    required String origin,
    required String originCountry,
    required String destination,
    required String destinationCountry,
    String? notes,
    List<CityModel>? stops,
    double? pricePerKg,
    double? minimumPrice,
    double? priceMultiplier,
  }) async {
    try {
      final newRoute = await _repository.createRoute(
        name: name,
        description: description,
        estimatedDurationHours: estimatedDurationHours,
        origin: origin,
        originCountry: originCountry,
        destination: destination,
        destinationCountry: destinationCountry,
        notes: notes,
        stops: stops,
        pricePerKg: pricePerKg,
        minimumPrice: minimumPrice,
        priceMultiplier: priceMultiplier,
      );
      state = state.copyWith(
        routes: [newRoute, ...state.routes],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRoute(String id) async {
    try {
      await _repository.deleteRoute(id);
      final routes = state.routes.where((r) => r.id != id).toList();
      state = state.copyWith(routes: routes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRoute({
    required String id,
    String? name,
    String? description,
    int? estimatedDurationHours,
    required String origin,
    required String originCountry,
    required String destination,
    required String destinationCountry,
    String? notes,
    List<CityModel>? stops,
    double? pricePerKg,
    double? minimumPrice,
    double? priceMultiplier,
  }) async {
    try {
      final data = <String, dynamic>{
        'origin_city': origin,
        'origin_country': originCountry,
        'destination_city': destination,
        'destination_country': destinationCountry,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (estimatedDurationHours != null)
          'estimated_duration_hours': estimatedDurationHours,
        if (notes != null) 'notes': notes,
        if (pricePerKg != null) 'price_per_kg': pricePerKg,
        if (minimumPrice != null) 'minimum_price': minimumPrice,
        if (priceMultiplier != null) 'price_multiplier': priceMultiplier,
        if (stops != null)
          'stops': stops
              .asMap()
              .entries
              .map((e) => {
                    'city': e.value.name,
                    'country': e.value.country,
                    'order': e.key,
                  })
              .toList(),
      };

      final updatedRoute = await _repository.updateRoute(id, data);
      final routes = state.routes.map((r) {
        return r.id == id ? updatedRoute : r;
      }).toList();
      state = state.copyWith(routes: routes);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Routes Provider
final routesProvider =
    StateNotifierProvider<RoutesNotifier, RoutesState>((ref) {
  return RoutesNotifier(ref.read(routeRepositoryProvider));
});

// Single Route Provider
final routeDetailProvider =
    FutureProvider.family<RouteModel, String>((ref, id) async {
  final repository = ref.read(routeRepositoryProvider);
  return repository.getRoute(id);
});

// Route Trips Provider
final routeTripsProvider =
    FutureProvider.family<List<TripModel>, String>((ref, routeId) async {
  final repository = ref.read(routeRepositoryProvider);
  return repository.getRouteTrips(routeId);
});
