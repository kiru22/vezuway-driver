import 'route_model.dart';

class RouteScheduleModel {
  final String? id;
  final DateTime departureDate;
  final DateTime? estimatedArrivalDate;
  final RouteStatus status;

  const RouteScheduleModel({
    this.id,
    required this.departureDate,
    this.estimatedArrivalDate,
    this.status = RouteStatus.planned,
  });

  factory RouteScheduleModel.fromJson(Map<String, dynamic> json) {
    // Parse status - handle both string and enum object formats
    String statusValue;
    if (json['status'] is String) {
      statusValue = json['status'];
    } else if (json['status'] is Map) {
      statusValue = json['status']['value'] ?? 'planned';
    } else {
      statusValue = 'planned';
    }

    return RouteScheduleModel(
      id: json['id']?.toString(),
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'])
          : DateTime.now(),
      estimatedArrivalDate: json['estimated_arrival_date'] != null
          ? DateTime.parse(json['estimated_arrival_date'])
          : null,
      status: RouteStatus.fromString(statusValue),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      if (estimatedArrivalDate != null)
        'estimated_arrival_date': estimatedArrivalDate!.toIso8601String().split('T')[0],
      'status': status.apiValue,
    };
  }

  RouteScheduleModel copyWith({
    String? id,
    DateTime? departureDate,
    DateTime? estimatedArrivalDate,
    RouteStatus? status,
  }) {
    return RouteScheduleModel(
      id: id ?? this.id,
      departureDate: departureDate ?? this.departureDate,
      estimatedArrivalDate: estimatedArrivalDate ?? this.estimatedArrivalDate,
      status: status ?? this.status,
    );
  }
}
