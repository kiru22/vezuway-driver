import 'route_model.dart';

class RouteScheduleModel {
  final int? id;
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
    return RouteScheduleModel(
      id: json['id'],
      departureDate: DateTime.parse(json['departure_date']),
      estimatedArrivalDate: json['estimated_arrival_date'] != null
          ? DateTime.parse(json['estimated_arrival_date'])
          : null,
      status: RouteStatus.fromString(json['status'] ?? 'planned'),
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
    int? id,
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
