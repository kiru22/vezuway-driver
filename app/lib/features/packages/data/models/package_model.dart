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
  final int? lengthCm;
  final int? widthCm;
  final int? heightCm;
  final int? quantity;
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
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.quantity,
    this.declaredValue,
    this.notes,
    this.ocrRawText,
    this.ocrParsedData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    // Support both nested (API v1) and flat structures
    final sender = json['sender'] as Map<String, dynamic>?;
    final receiver = json['receiver'] as Map<String, dynamic>?;
    final dimensions = json['dimensions'] as Map<String, dynamic>?;
    final ocr = json['ocr'] as Map<String, dynamic>?;

    return PackageModel(
      id: json['id'],
      routeId: json['route_id'],
      trackingCode: json['tracking_code'],
      status: PackageStatus.fromString(json['status']),
      senderName: sender?['name'] ?? json['sender_name'] ?? '',
      senderPhone: sender?['phone'] ?? json['sender_phone'],
      senderAddress: sender?['address'] ?? json['sender_address'],
      receiverName: receiver?['name'] ?? json['receiver_name'] ?? '',
      receiverPhone: receiver?['phone'] ?? json['receiver_phone'],
      receiverAddress: receiver?['address'] ?? json['receiver_address'],
      description: json['description'],
      weight: _parseDouble(json['weight'] ?? dimensions?['weight_kg']),
      lengthCm: _parseInt(json['length_cm'] ?? dimensions?['length_cm']),
      widthCm: _parseInt(json['width_cm'] ?? dimensions?['width_cm']),
      heightCm: _parseInt(json['height_cm'] ?? dimensions?['height_cm']),
      quantity: _parseInt(json['quantity']),
      declaredValue: _parseDouble(json['declared_value']),
      notes: json['notes'],
      ocrRawText: ocr?['raw_text'] ?? json['ocr_raw_text'],
      ocrParsedData: json['ocr_parsed_data'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Parse a value to double, handling both String and num
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse a value to int, handling both String and num
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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
      'length_cm': lengthCm,
      'width_cm': widthCm,
      'height_cm': heightCm,
      'quantity': quantity,
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
    int? lengthCm,
    int? widthCm,
    int? heightCm,
    int? quantity,
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
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      quantity: quantity ?? this.quantity,
      declaredValue: declaredValue ?? this.declaredValue,
      notes: notes ?? this.notes,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      ocrParsedData: ocrParsedData ?? this.ocrParsedData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
