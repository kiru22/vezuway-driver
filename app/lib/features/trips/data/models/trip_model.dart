import 'package:flutter/material.dart';

import 'trip_status.dart';
import 'trip_stop_model.dart';

class TripModel {
  final String id;
  final String? routeId;
  final String originCity;
  final String originCountry;
  final String destinationCity;
  final String destinationCountry;
  final DateTime departureDate;
  final TimeOfDay? departureTime;
  final DateTime? estimatedArrivalDate;
  final DateTime? actualArrivalDate;
  final TripStatus status;
  final String? notes;
  final int packagesCount;
  final List<TripStopModel> stops;
  final double? pricePerKg;
  final double? minimumPrice;
  final double? priceMultiplier;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripModel({
    required this.id,
    this.routeId,
    required this.originCity,
    this.originCountry = 'UA',
    required this.destinationCity,
    this.destinationCountry = 'ES',
    required this.departureDate,
    this.departureTime,
    this.estimatedArrivalDate,
    this.actualArrivalDate,
    required this.status,
    this.notes,
    this.packagesCount = 0,
    this.stops = const [],
    this.pricePerKg,
    this.minimumPrice,
    this.priceMultiplier,
    this.currency = 'EUR',
    required this.createdAt,
    required this.updatedAt,
  });

  String get name => '$originCity - $destinationCity';

  String get displayName => name;

  String get formattedDepartureTime {
    if (departureTime == null) return '';
    final hour = departureTime!.hour.toString().padLeft(2, '0');
    final minute = departureTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Handle both nested and flat origin/destination
    String originCity;
    String originCountry;
    String destCity;
    String destCountry;

    if (json['origin'] is Map) {
      originCity = json['origin']['city'] ?? '';
      originCountry = json['origin']['country'] ?? 'UA';
    } else {
      originCity = json['origin'] ?? json['origin_city'] ?? '';
      originCountry = json['origin_country'] ?? 'UA';
    }

    if (json['destination'] is Map) {
      destCity = json['destination']['city'] ?? '';
      destCountry = json['destination']['country'] ?? 'ES';
    } else {
      destCity = json['destination'] ?? json['destination_city'] ?? '';
      destCountry = json['destination_country'] ?? 'ES';
    }

    // Parse stops
    final stopsJson = json['stops'] as List<dynamic>? ?? [];
    final stops = stopsJson
        .map((s) => TripStopModel.fromJson(s as Map<String, dynamic>))
        .toList();

    // Parse pricing
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final pricing = json['pricing'] as Map<String, dynamic>?;
    final pricePerKg = pricing != null
        ? parsePrice(pricing['price_per_kg'])
        : parsePrice(json['price_per_kg']);
    final minimumPrice = pricing != null
        ? parsePrice(pricing['minimum_price'])
        : parsePrice(json['minimum_price']);
    final priceMultiplier = pricing != null
        ? parsePrice(pricing['multiplier'])
        : parsePrice(json['price_multiplier']);
    final currency = pricing?['currency'] ?? json['currency'] ?? 'EUR';

    // Parse status
    String statusValue;
    if (json['status'] is String) {
      statusValue = json['status'];
    } else if (json['status'] is Map) {
      statusValue = json['status']['value'] ?? 'planned';
    } else {
      statusValue = 'planned';
    }

    // Parse departure time
    TimeOfDay? departureTime;
    if (json['departure_time'] != null) {
      final parts = json['departure_time'].toString().split(':');
      if (parts.length >= 2) {
        departureTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    return TripModel(
      id: json['id'].toString(),
      routeId: json['route_id']?.toString(),
      originCity: originCity,
      originCountry: originCountry,
      destinationCity: destCity,
      destinationCountry: destCountry,
      departureDate: DateTime.parse(json['departure_date']),
      departureTime: departureTime,
      estimatedArrivalDate: json['estimated_arrival_date'] != null
          ? DateTime.parse(json['estimated_arrival_date'])
          : null,
      actualArrivalDate: json['actual_arrival_date'] != null
          ? DateTime.parse(json['actual_arrival_date'])
          : null,
      status: TripStatus.fromString(statusValue),
      notes: json['notes'],
      packagesCount: json['packages_count'] ?? 0,
      stops: stops,
      pricePerKg: pricePerKg,
      minimumPrice: minimumPrice,
      priceMultiplier: priceMultiplier,
      currency: currency,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'origin_city': originCity,
      'origin_country': originCountry,
      'destination_city': destinationCity,
      'destination_country': destinationCountry,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      'departure_time': departureTime != null
          ? '${departureTime!.hour.toString().padLeft(2, '0')}:${departureTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'estimated_arrival_date':
          estimatedArrivalDate?.toIso8601String().split('T')[0],
      'notes': notes,
      'price_per_kg': pricePerKg,
      'minimum_price': minimumPrice,
      'price_multiplier': priceMultiplier,
      'currency': currency,
      'stops': stops
          .asMap()
          .entries
          .map((e) => {
                'city': e.value.city,
                'country': e.value.country,
                'order': e.key,
              })
          .toList(),
    };
  }

  TripModel copyWith({
    String? id,
    String? routeId,
    String? originCity,
    String? originCountry,
    String? destinationCity,
    String? destinationCountry,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    DateTime? estimatedArrivalDate,
    DateTime? actualArrivalDate,
    TripStatus? status,
    String? notes,
    int? packagesCount,
    List<TripStopModel>? stops,
    double? pricePerKg,
    double? minimumPrice,
    double? priceMultiplier,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      originCity: originCity ?? this.originCity,
      originCountry: originCountry ?? this.originCountry,
      destinationCity: destinationCity ?? this.destinationCity,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrivalDate: estimatedArrivalDate ?? this.estimatedArrivalDate,
      actualArrivalDate: actualArrivalDate ?? this.actualArrivalDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      packagesCount: packagesCount ?? this.packagesCount,
      stops: stops ?? this.stops,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      minimumPrice: minimumPrice ?? this.minimumPrice,
      priceMultiplier: priceMultiplier ?? this.priceMultiplier,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
