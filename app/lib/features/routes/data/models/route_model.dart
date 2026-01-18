import '../../../../shared/models/city_model.dart';
import 'route_schedule_model.dart';

enum RouteStatus {
  planned,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case RouteStatus.planned:
        return 'Planificada';
      case RouteStatus.inProgress:
        return 'En progreso';
      case RouteStatus.completed:
        return 'Completada';
      case RouteStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get apiValue {
    switch (this) {
      case RouteStatus.planned:
        return 'planned';
      case RouteStatus.inProgress:
        return 'in_progress';
      case RouteStatus.completed:
        return 'completed';
      case RouteStatus.cancelled:
        return 'cancelled';
    }
  }

  static RouteStatus fromString(String value) {
    switch (value) {
      case 'planned':
        return RouteStatus.planned;
      case 'in_progress':
        return RouteStatus.inProgress;
      case 'completed':
        return RouteStatus.completed;
      case 'cancelled':
        return RouteStatus.cancelled;
      default:
        return RouteStatus.planned;
    }
  }
}

class RouteModel {
  final String id;
  final String origin;
  final String originCountry;
  final String destination;
  final String destinationCountry;
  final RouteStatus status;
  final DateTime departureDate;
  final DateTime? arrivalDate;
  final String? notes;
  final int packagesCount;
  final List<RouteScheduleModel> schedules;
  final List<CityModel> stops;
  final double? pricePerKg;
  final double? minimumPrice;
  final double? priceMultiplier;
  final DateTime createdAt;
  final DateTime updatedAt;

  RouteModel({
    required this.id,
    required this.origin,
    this.originCountry = 'ES',
    required this.destination,
    this.destinationCountry = 'UA',
    required this.status,
    required this.departureDate,
    this.arrivalDate,
    this.notes,
    this.packagesCount = 0,
    this.schedules = const [],
    this.stops = const [],
    this.pricePerKg,
    this.minimumPrice,
    this.priceMultiplier,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper to get all departure dates from schedules
  List<DateTime> get allDepartureDates {
    if (schedules.isEmpty) return [departureDate];
    return schedules.map((s) => s.departureDate).toList()..sort();
  }

  // Returns the next future departure date, or null if all dates have passed
  DateTime? get nextDepartureDate {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final futureDates = allDepartureDates.where((d) => !d.isBefore(todayStart)).toList();
    return futureDates.isNotEmpty ? futureDates.first : null;
  }

  // Returns true if this route has any future departure dates
  bool get hasUpcomingDates => nextDepartureDate != null;

  // Helper to get display name (origin -> destination)
  String get name => '$origin - $destination';

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // Handle both nested and flat origin/destination
    String originCity;
    String originCountry;
    String destCity;
    String destCountry;

    if (json['origin'] is Map) {
      originCity = json['origin']['city'] ?? '';
      originCountry = json['origin']['country'] ?? 'ES';
    } else {
      originCity = json['origin'] ?? json['origin_city'] ?? '';
      originCountry = json['origin_country'] ?? 'ES';
    }

    if (json['destination'] is Map) {
      destCity = json['destination']['city'] ?? '';
      destCountry = json['destination']['country'] ?? 'UA';
    } else {
      destCity = json['destination'] ?? json['destination_city'] ?? '';
      destCountry = json['destination_country'] ?? 'UA';
    }

    // Parse schedules if present
    final schedulesJson = json['schedules'] as List<dynamic>? ?? [];
    final schedules = schedulesJson
        .map((s) => RouteScheduleModel.fromJson(s as Map<String, dynamic>))
        .toList();

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

    // Parse status - handle both string and enum object formats
    String statusValue;
    if (json['status'] is String) {
      statusValue = json['status'];
    } else if (json['status'] is Map) {
      statusValue = json['status']['value'] ?? 'planned';
    } else {
      statusValue = 'planned';
    }

    // Parse dates with null safety
    DateTime departureDate;
    if (json['departure_date'] != null) {
      departureDate = DateTime.parse(json['departure_date']);
    } else if (schedules.isNotEmpty) {
      departureDate = schedules.first.departureDate;
    } else {
      departureDate = DateTime.now();
    }

    DateTime? arrivalDate;
    if (json['estimated_arrival_date'] != null) {
      arrivalDate = DateTime.parse(json['estimated_arrival_date']);
    } else if (json['arrival_date'] != null) {
      arrivalDate = DateTime.parse(json['arrival_date']);
    } else if (json['actual_arrival_date'] != null) {
      arrivalDate = DateTime.parse(json['actual_arrival_date']);
    }

    return RouteModel(
      id: json['id'].toString(),
      origin: originCity,
      originCountry: originCountry,
      destination: destCity,
      destinationCountry: destCountry,
      status: RouteStatus.fromString(statusValue),
      departureDate: departureDate,
      arrivalDate: arrivalDate,
      notes: json['notes'],
      packagesCount: json['packages_count'] ?? 0,
      schedules: schedules,
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
      'origin_city': origin,
      'origin_country': originCountry,
      'destination_city': destination,
      'destination_country': destinationCountry,
      'status': status.apiValue,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      'estimated_arrival_date': arrivalDate?.toIso8601String().split('T')[0],
      'notes': notes,
      'price_per_kg': pricePerKg,
      'minimum_price': minimumPrice,
      'price_multiplier': priceMultiplier,
      'stops': stops.asMap().entries.map((e) => {
        'city': e.value.name,
        'country': e.value.country,
        'order': e.key,
      }).toList(),
    };
  }

  RouteModel copyWith({
    String? id,
    String? origin,
    String? originCountry,
    String? destination,
    String? destinationCountry,
    RouteStatus? status,
    DateTime? departureDate,
    DateTime? arrivalDate,
    String? notes,
    int? packagesCount,
    List<RouteScheduleModel>? schedules,
    List<CityModel>? stops,
    double? pricePerKg,
    double? minimumPrice,
    double? priceMultiplier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      originCountry: originCountry ?? this.originCountry,
      destination: destination ?? this.destination,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      status: status ?? this.status,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      notes: notes ?? this.notes,
      packagesCount: packagesCount ?? this.packagesCount,
      schedules: schedules ?? this.schedules,
      stops: stops ?? this.stops,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      minimumPrice: minimumPrice ?? this.minimumPrice,
      priceMultiplier: priceMultiplier ?? this.priceMultiplier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
