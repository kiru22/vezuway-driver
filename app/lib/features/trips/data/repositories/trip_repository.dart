import 'package:flutter/material.dart';

import '../../../../core/services/api_service.dart';
import '../../../../shared/models/city_model.dart';
import '../../../packages/data/models/package_model.dart';
import '../models/trip_model.dart';
import '../models/trip_status.dart';

class TripRepository {
  final ApiService _api;

  TripRepository(this._api);

  Future<List<TripModel>> getTrips({
    TripStatus? status,
    bool? upcoming,
    bool? active,
    String? from,
    String? to,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.apiValue;
    if (upcoming == true) queryParams['upcoming'] = true;
    if (active == true) queryParams['active'] = true;
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    final response = await _api.get('/trips', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => TripModel.fromJson(json)).toList();
  }

  Future<TripModel> getTrip(String id) async {
    final response = await _api.get('/trips/$id');
    final data = response.data['data'] ?? response.data;
    return TripModel.fromJson(data);
  }

  Future<TripModel> createTrip({
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
    final response = await _api.post('/trips', data: {
      if (routeId != null) 'route_id': routeId,
      'origin_city': originCity,
      'origin_country': originCountry,
      'destination_city': destinationCity,
      'destination_country': destinationCountry,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      if (departureTime != null)
        'departure_time':
            '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}',
      if (estimatedArrivalDate != null)
        'estimated_arrival_date':
            estimatedArrivalDate.toIso8601String().split('T')[0],
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
    return TripModel.fromJson(data);
  }

  Future<TripModel> createTripFromRoute({
    required String routeId,
    required DateTime departureDate,
    TimeOfDay? departureTime,
    DateTime? estimatedArrivalDate,
    String? notes,
  }) async {
    final response = await _api.post('/routes/$routeId/trips', data: {
      'departure_date': departureDate.toIso8601String().split('T')[0],
      if (departureTime != null)
        'departure_time':
            '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}',
      if (estimatedArrivalDate != null)
        'estimated_arrival_date':
            estimatedArrivalDate.toIso8601String().split('T')[0],
      if (notes != null) 'notes': notes,
    });
    final data = response.data['data'] ?? response.data;
    return TripModel.fromJson(data);
  }

  Future<TripModel> updateTrip(String id, Map<String, dynamic> data) async {
    final response = await _api.put('/trips/$id', data: data);
    final responseData = response.data['data'] ?? response.data;
    return TripModel.fromJson(responseData);
  }

  Future<TripModel> updateStatus(String id, TripStatus status) async {
    final response = await _api.patch('/trips/$id/status', data: {
      'status': status.apiValue,
    });
    final data = response.data['data'] ?? response.data;
    return TripModel.fromJson(data);
  }

  Future<void> deleteTrip(String id) async {
    await _api.delete('/trips/$id');
  }

  Future<List<PackageModel>> getTripPackages(String id) async {
    final response = await _api.get('/trips/$id/packages');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => PackageModel.fromJson(json)).toList();
  }

  Future<void> assignPackages(String tripId, List<String> packageIds) async {
    await _api.post('/trips/$tripId/packages', data: {
      'package_ids': packageIds,
    });
  }
}
