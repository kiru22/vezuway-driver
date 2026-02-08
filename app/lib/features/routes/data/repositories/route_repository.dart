import '../../../../core/services/api_service.dart';
import '../../../../shared/models/city_model.dart';
import '../../../trips/data/models/trip_model.dart';
import '../models/route_model.dart';

class RouteRepository {
  final ApiService _api;

  RouteRepository(this._api);

  Future<List<RouteModel>> getRoutes({
    bool? activeOnly,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (activeOnly == true) queryParams['active_only'] = true;

    final response = await _api.get('/routes', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => RouteModel.fromJson(json)).toList();
  }

  Future<RouteModel> getRoute(String id) async {
    final response = await _api.get('/routes/$id');
    final data = response.data['data'] ?? response.data;
    return RouteModel.fromJson(data);
  }

  Future<RouteModel> createRoute({
    String? name,
    String? description,
    int? estimatedDurationHours,
    required String origin,
    required String destination,
    String originCountry = 'UA',
    String destinationCountry = 'ES',
    String? notes,
    List<CityModel>? stops,
    double? pricePerKg,
    double? minimumPrice,
    double? priceMultiplier,
  }) async {
    final response = await _api.post('/routes', data: {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (estimatedDurationHours != null)
        'estimated_duration_hours': estimatedDurationHours,
      'origin_city': origin,
      'origin_country': originCountry,
      'destination_city': destination,
      'destination_country': destinationCountry,
      if (notes != null) 'notes': notes,
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
      if (minimumPrice != null) 'minimum_price': minimumPrice,
      if (priceMultiplier != null) 'price_multiplier': priceMultiplier,
      if (stops != null && stops.isNotEmpty)
        'stops': stops
            .asMap()
            .entries
            .map((e) => {
                  'city': e.value.name,
                  'country': e.value.country,
                  'order': e.key,
                })
            .toList(),
    });
    final data = response.data['data'] ?? response.data;
    return RouteModel.fromJson(data);
  }

  Future<RouteModel> updateRoute(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/routes/$id', data: data);
    final responseData = response.data['data'] ?? response.data;
    return RouteModel.fromJson(responseData);
  }

  Future<void> deleteRoute(String id) async {
    await _api.delete('/routes/$id');
  }

  Future<List<TripModel>> getRouteTrips(String id) async {
    final response = await _api.get('/routes/$id/trips');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => TripModel.fromJson(json)).toList();
  }
}
