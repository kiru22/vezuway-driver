import '../../../../shared/models/city_model.dart';

class RouteModel {
  final String id;
  final String? name;
  final String? description;
  final bool isActive;
  final int? estimatedDurationHours;
  final String origin;
  final String originCountry;
  final String destination;
  final String destinationCountry;
  final String? notes;
  final int tripsCount;
  final List<CityModel> stops;
  final double? pricePerKg;
  final double? minimumPrice;
  final double? priceMultiplier;
  final DateTime createdAt;
  final DateTime updatedAt;

  RouteModel({
    required this.id,
    this.name,
    this.description,
    this.isActive = true,
    this.estimatedDurationHours,
    required this.origin,
    this.originCountry = 'UA',
    required this.destination,
    this.destinationCountry = 'ES',
    this.notes,
    this.tripsCount = 0,
    this.stops = const [],
    this.pricePerKg,
    this.minimumPrice,
    this.priceMultiplier,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => name ?? '$origin - $destination';

  factory RouteModel.fromJson(Map<String, dynamic> json) {
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

    // Parse stops if present
    final stopsJson = json['stops'] as List<dynamic>? ?? [];
    final stops = stopsJson
        .map((s) => CityModel.fromJson(s as Map<String, dynamic>))
        .toList();

    // Parse pricing - handle both String and num types
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

    return RouteModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      estimatedDurationHours: json['estimated_duration_hours'],
      origin: originCity,
      originCountry: originCountry,
      destination: destCity,
      destinationCountry: destCountry,
      notes: json['notes'],
      tripsCount: json['trips_count'] ?? 0,
      stops: stops,
      pricePerKg: pricePerKg,
      minimumPrice: minimumPrice,
      priceMultiplier: priceMultiplier,
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
      'name': name,
      'description': description,
      'is_active': isActive,
      'estimated_duration_hours': estimatedDurationHours,
      'origin_city': origin,
      'origin_country': originCountry,
      'destination_city': destination,
      'destination_country': destinationCountry,
      'notes': notes,
      'price_per_kg': pricePerKg,
      'minimum_price': minimumPrice,
      'price_multiplier': priceMultiplier,
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
  }

  RouteModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    int? estimatedDurationHours,
    String? origin,
    String? originCountry,
    String? destination,
    String? destinationCountry,
    String? notes,
    int? tripsCount,
    List<CityModel>? stops,
    double? pricePerKg,
    double? minimumPrice,
    double? priceMultiplier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      estimatedDurationHours:
          estimatedDurationHours ?? this.estimatedDurationHours,
      origin: origin ?? this.origin,
      originCountry: originCountry ?? this.originCountry,
      destination: destination ?? this.destination,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      notes: notes ?? this.notes,
      tripsCount: tripsCount ?? this.tripsCount,
      stops: stops ?? this.stops,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      minimumPrice: minimumPrice ?? this.minimumPrice,
      priceMultiplier: priceMultiplier ?? this.priceMultiplier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
