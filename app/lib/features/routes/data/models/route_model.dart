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
  final int id;
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
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper to get all departure dates from schedules
  List<DateTime> get allDepartureDates {
    if (schedules.isEmpty) return [departureDate];
    return schedules.map((s) => s.departureDate).toList()..sort();
  }

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

    return RouteModel(
      id: json['id'],
      origin: originCity,
      originCountry: originCountry,
      destination: destCity,
      destinationCountry: destCountry,
      status: RouteStatus.fromString(json['status'] is String
          ? json['status']
          : json['status']?['value'] ?? 'planned'),
      departureDate: DateTime.parse(json['departure_date']),
      arrivalDate: json['estimated_arrival_date'] != null
          ? DateTime.parse(json['estimated_arrival_date'])
          : (json['arrival_date'] != null
              ? DateTime.parse(json['arrival_date'])
              : null),
      notes: json['notes'],
      packagesCount: json['packages_count'] ?? 0,
      schedules: schedules,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
    };
  }

  RouteModel copyWith({
    int? id,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
