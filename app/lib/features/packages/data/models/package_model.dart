enum PackageStatus {
  pending,
  pickedUp,
  inTransit,
  inWarehouse,
  outForDelivery,
  delivered,
  cancelled,
  returned;

  String get displayName {
    switch (this) {
      case PackageStatus.pending:
        return 'Pendiente';
      case PackageStatus.pickedUp:
        return 'Recogido';
      case PackageStatus.inTransit:
        return 'En transito';
      case PackageStatus.inWarehouse:
        return 'En almacen';
      case PackageStatus.outForDelivery:
        return 'En reparto';
      case PackageStatus.delivered:
        return 'Entregado';
      case PackageStatus.cancelled:
        return 'Cancelado';
      case PackageStatus.returned:
        return 'Devuelto';
    }
  }

  String get apiValue {
    switch (this) {
      case PackageStatus.pending:
        return 'pending';
      case PackageStatus.pickedUp:
        return 'picked_up';
      case PackageStatus.inTransit:
        return 'in_transit';
      case PackageStatus.inWarehouse:
        return 'in_warehouse';
      case PackageStatus.outForDelivery:
        return 'out_for_delivery';
      case PackageStatus.delivered:
        return 'delivered';
      case PackageStatus.cancelled:
        return 'cancelled';
      case PackageStatus.returned:
        return 'returned';
    }
  }

  static PackageStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PackageStatus.pending;
      case 'picked_up':
        return PackageStatus.pickedUp;
      case 'in_transit':
        return PackageStatus.inTransit;
      case 'in_warehouse':
        return PackageStatus.inWarehouse;
      case 'out_for_delivery':
        return PackageStatus.outForDelivery;
      case 'delivered':
        return PackageStatus.delivered;
      case 'cancelled':
        return PackageStatus.cancelled;
      case 'returned':
        return PackageStatus.returned;
      default:
        return PackageStatus.pending;
    }
  }
}

class PackageModel {
  final int id;
  final int? routeId;
  final String trackingCode;
  final PackageStatus status;
  final String senderName;
  final String? senderPhone;
  final String? senderAddress;
  final String receiverName;
  final String? receiverPhone;
  final String? receiverAddress;
  final String? description;
  final double? weight;
  final double? declaredValue;
  final String? notes;
  final String? ocrRawText;
  final Map<String, dynamic>? ocrParsedData;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackageModel({
    required this.id,
    this.routeId,
    required this.trackingCode,
    required this.status,
    required this.senderName,
    this.senderPhone,
    this.senderAddress,
    required this.receiverName,
    this.receiverPhone,
    this.receiverAddress,
    this.description,
    this.weight,
    this.declaredValue,
    this.notes,
    this.ocrRawText,
    this.ocrParsedData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      routeId: json['route_id'],
      trackingCode: json['tracking_code'],
      status: PackageStatus.fromString(json['status']),
      senderName: json['sender_name'],
      senderPhone: json['sender_phone'],
      senderAddress: json['sender_address'],
      receiverName: json['receiver_name'],
      receiverPhone: json['receiver_phone'],
      receiverAddress: json['receiver_address'],
      description: json['description'],
      weight: json['weight']?.toDouble(),
      declaredValue: json['declared_value']?.toDouble(),
      notes: json['notes'],
      ocrRawText: json['ocr_raw_text'],
      ocrParsedData: json['ocr_parsed_data'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'tracking_code': trackingCode,
      'status': status.apiValue,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'sender_address': senderAddress,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'receiver_address': receiverAddress,
      'description': description,
      'weight': weight,
      'declared_value': declaredValue,
      'notes': notes,
    };
  }

  PackageModel copyWith({
    int? id,
    int? routeId,
    String? trackingCode,
    PackageStatus? status,
    String? senderName,
    String? senderPhone,
    String? senderAddress,
    String? receiverName,
    String? receiverPhone,
    String? receiverAddress,
    String? description,
    double? weight,
    double? declaredValue,
    String? notes,
    String? ocrRawText,
    Map<String, dynamic>? ocrParsedData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      trackingCode: trackingCode ?? this.trackingCode,
      status: status ?? this.status,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      senderAddress: senderAddress ?? this.senderAddress,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      declaredValue: declaredValue ?? this.declaredValue,
      notes: notes ?? this.notes,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      ocrParsedData: ocrParsedData ?? this.ocrParsedData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
