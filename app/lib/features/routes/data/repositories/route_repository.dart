import '../../../../core/services/api_service.dart';
import '../../../packages/data/models/package_model.dart';
import '../models/route_model.dart';

class RouteRepository {
  final ApiService _api;

  RouteRepository(this._api);

  Future<List<RouteModel>> getRoutes({RouteStatus? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.apiValue;

    final response = await _api.get('/routes', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => RouteModel.fromJson(json)).toList();
  }

  Future<RouteModel> getRoute(int id) async {
    final response = await _api.get('/routes/$id');
    final data = response.data['data'] ?? response.data;
    return RouteModel.fromJson(data);
  }

  Future<RouteModel> createRoute({
    required String origin,
    required String destination,
    required List<DateTime> departureDates,
    int? tripDurationHours,
    String? notes,
    String originCountry = 'ES',
    String destinationCountry = 'UA',
  }) async {
    final response = await _api.post('/routes', data: {
      'origin_city': origin,
      'origin_country': originCountry,
      'destination_city': destination,
      'destination_country': destinationCountry,
      'departure_dates': departureDates
          .map((d) => d.toIso8601String().split('T')[0])
          .toList(),
      if (tripDurationHours != null) 'trip_duration_hours': tripDurationHours,
      if (notes != null) 'notes': notes,
    });
    final data = response.data['data'] ?? response.data;
    return RouteModel.fromJson(data);
  }

  Future<RouteModel> updateRoute(int id, Map<String, dynamic> data) async {
    final response = await _api.put('/routes/$id', data: data);
    final responseData = response.data['data'] ?? response.data;
    return RouteModel.fromJson(responseData);
  }

  Future<RouteModel> updateStatus(int id, RouteStatus status) async {
    final response = await _api.patch('/routes/$id/status', data: {
      'status': status.apiValue,
    });
    final data = response.data['data'] ?? response.data;
    return RouteModel.fromJson(data);
  }

  Future<void> deleteRoute(int id) async {
    await _api.delete('/routes/$id');
  }

  Future<List<PackageModel>> getRoutePackages(int id) async {
    final response = await _api.get('/routes/$id/packages');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => PackageModel.fromJson(json)).toList();
  }

  Future<void> assignPackages(int routeId, List<int> packageIds) async {
    await _api.post('/routes/$routeId/packages', data: {
      'package_ids': packageIds,
    });
  }
}
