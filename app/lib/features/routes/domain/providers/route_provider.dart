import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/city_model.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/route_repository.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(ref.read(apiServiceProvider));
});

class RoutesState {
  final List<RouteModel> routes;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const RoutesState({
    this.routes = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  RoutesState copyWith({
    List<RouteModel>? routes,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return RoutesState(
      routes: routes ?? this.routes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class RoutesNotifier extends StateNotifier<RoutesState> {
  final RouteRepository _repository;
  bool _isInitialized = false;

  RoutesNotifier(this._repository) : super(const RoutesState()) {
    _init();
  }

  static const _perPage = 15;
  bool? _currentActiveOnly;

  Future<void> _init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await loadRoutes(refresh: true);
  }

  Future<void> loadRoutes({bool? activeOnly, bool refresh = false}) async {
    if (state.isLoading) return;

    if (activeOnly != null) _currentActiveOnly = activeOnly;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        hasMore: true,
        currentPage: 1,
        routes: [],
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final page = refresh ? 1 : state.currentPage;
      final routes = await _repository.getRoutes(
        activeOnly: _currentActiveOnly,
        page: page,
        perPage: _perPage,
      );
      state = state.copyWith(
        routes: refresh ? routes : [...state.routes, ...routes],
        isLoading: false,
        hasMore: routes.length >= _perPage,
        currentPage: page + 1,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar plantillas de rutas',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadRoutes();
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

final routesProvider =
    StateNotifierProvider<RoutesNotifier, RoutesState>((ref) {
  return RoutesNotifier(ref.read(routeRepositoryProvider));
});

final routeDetailProvider =
    FutureProvider.family<RouteModel, String>((ref, id) async {
  final repository = ref.read(routeRepositoryProvider);
  return repository.getRoute(id);
});

final routeTripsProvider =
    FutureProvider.family<List<TripModel>, String>((ref, routeId) async {
  final repository = ref.read(routeRepositoryProvider);
  return repository.getRouteTrips(routeId);
});
