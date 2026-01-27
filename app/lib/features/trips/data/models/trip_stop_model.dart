enum TripStopStatus {
  pending,
  arrived,
  departed,
  skipped;

  String get displayName {
    switch (this) {
      case TripStopStatus.pending:
        return 'Pendiente';
      case TripStopStatus.arrived:
        return 'Llegado';
      case TripStopStatus.departed:
        return 'Partió';
      case TripStopStatus.skipped:
        return 'Omitido';
    }
  }

  String get apiValue {
    switch (this) {
      case TripStopStatus.pending:
        return 'pending';
      case TripStopStatus.arrived:
        return 'arrived';
      case TripStopStatus.departed:
        return 'departed';
      case TripStopStatus.skipped:
        return 'skipped';
    }
  }

  static TripStopStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return TripStopStatus.pending;
      case 'arrived':
        return TripStopStatus.arrived;
      case 'departed':
        return TripStopStatus.departed;
      case 'skipped':
        return TripStopStatus.skipped;
      default:
        return TripStopStatus.pending;
    }
  }
}

class TripStopModel {
  final String id;
  final String city;
  final String country;
  final int order;
  final TripStopStatus status;
  final DateTime? arrivedAt;
  final DateTime? departedAt;

  TripStopModel({
    required this.id,
    required this.city,
    required this.country,
    required this.order,
    this.status = TripStopStatus.pending,
    this.arrivedAt,
    this.departedAt,
  });

  factory TripStopModel.fromJson(Map<String, dynamic> json) {
    String statusValue = 'pending';
    if (json['status'] is String) {
      statusValue = json['status'];
    } else if (json['status'] is Map) {
      statusValue = json['status']['value'] ?? 'pending';
    }

    return TripStopModel(
      id: json['id'].toString(),
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      order: json['order'] ?? 0,
      status: TripStopStatus.fromString(statusValue),
      arrivedAt: json['arrived_at'] != null
          ? DateTime.parse(json['arrived_at'])
          : null,
      departedAt: json['departed_at'] != null
          ? DateTime.parse(json['departed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'country': country,
      'order': order,
      'status': status.apiValue,
    };
  }

  TripStopModel copyWith({
    String? id,
    String? city,
    String? country,
    int? order,
    TripStopStatus? status,
    DateTime? arrivedAt,
    DateTime? departedAt,
  }) {
    return TripStopModel(
      id: id ?? this.id,
      city: city ?? this.city,
      country: country ?? this.country,
      order: order ?? this.order,
      status: status ?? this.status,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      departedAt: departedAt ?? this.departedAt,
    );
  }
}
