import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/route_repository.dart';

// Route Repository Provider
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(ref.watch(apiServiceProvider));
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

  RoutesNotifier(this._repository) : super(const RoutesState()) {
    loadRoutes();
  }

  Future<void> loadRoutes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final routes = await _repository.getRoutes();
      state = state.copyWith(routes: routes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar rutas',
      );
    }
  }

  Future<bool> createRoute({
    required String origin,
    required String destination,
    required List<DateTime> departureDates,
    int? tripDurationHours,
    String? notes,
  }) async {
    try {
      final newRoute = await _repository.createRoute(
        origin: origin,
        destination: destination,
        departureDates: departureDates,
        tripDurationHours: tripDurationHours,
        notes: notes,
      );
      state = state.copyWith(
        routes: [newRoute, ...state.routes],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(int id, RouteStatus status) async {
    try {
      final updated = await _repository.updateStatus(id, status);
      final routes = state.routes.map((r) {
        return r.id == id ? updated : r;
      }).toList();
      state = state.copyWith(routes: routes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRoute(int id) async {
    try {
      await _repository.deleteRoute(id);
      final routes = state.routes.where((r) => r.id != id).toList();
      state = state.copyWith(routes: routes);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Routes Provider
final routesProvider = StateNotifierProvider<RoutesNotifier, RoutesState>((ref) {
  return RoutesNotifier(ref.watch(routeRepositoryProvider));
});

// Single Route Provider
final routeDetailProvider = FutureProvider.family<RouteModel, int>((ref, id) async {
  final repository = ref.watch(routeRepositoryProvider);
  return repository.getRoute(id);
});
