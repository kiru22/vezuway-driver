int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

enum PackageStatus {
  registered, // Оформлено
  inTransit, // В дорозі
  delivered, // Видано
  delayed; // Затримується

  String get apiValue {
    switch (this) {
      case PackageStatus.registered:
        return 'pending'; // Changed from 'registered' to match DB
      case PackageStatus.inTransit:
        return 'in_transit';
      case PackageStatus.delivered:
        return 'delivered';
      case PackageStatus.delayed:
        return 'delayed';
    }
  }

  static PackageStatus fromString(String? value) {
    switch (value ?? 'pending') {
      case 'registered':
      case 'pending':
      case 'picked_up':
        return PackageStatus.registered;
      case 'in_transit':
      case 'in_warehouse':
      case 'out_for_delivery':
        return PackageStatus.inTransit;
      case 'delivered':
        return PackageStatus.delivered;
      case 'delayed':
        return PackageStatus.delayed;
      default:
        return PackageStatus.registered;
    }
  }
}

/// Información resumida de la ruta asociada al paquete
class RouteInfo {
  final String id;
  final String origin;
  final String destination;
  final String? departureDate;

  RouteInfo({
    required this.id,
    required this.origin,
    required this.destination,
    this.departureDate,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'].toString(),
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      departureDate: json['departure_date'],
    );
  }
}

/// Información de una imagen del paquete
class PackageImage {
  final String id;
  final String url;
  final String? thumbUrl;

  PackageImage({
    required this.id,
    required this.url,
    this.thumbUrl,
  });

  factory PackageImage.fromJson(Map<String, dynamic> json) {
    return PackageImage(
      id: json['id'].toString(),
      url: json['url'] ?? '',
      thumbUrl: json['thumb_url'],
    );
  }
}

/// Información resumida de un contacto asociado al paquete
class ContactInfo {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final int totalPackages;
  final bool isVerified;

  ContactInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.totalPackages,
    required this.isVerified,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      totalPackages: _toInt(json['total_packages']),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class PackageModel {
  final String id;
  final String? routeId;
  final String? tripId;
  final String? senderContactId;
  final String? receiverContactId;
  final RouteInfo? route;
  final ContactInfo? senderContact;
  final ContactInfo? receiverContact;
  final String trackingCode;
  final String? publicId;
  final PackageStatus status;
  final String senderName;
  final String? senderPhone;
  final String? senderAddress;
  final String? senderCity;
  final String? senderCountry;
  final String receiverName;
  final String? receiverPhone;
  final String? receiverAddress;
  final String? receiverCity;
  final String? receiverCountry;
  final String? novaPostNumber;
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
  final List<PackageImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackageModel({
    required this.id,
    this.routeId,
    this.tripId,
    this.senderContactId,
    this.receiverContactId,
    this.route,
    this.senderContact,
    this.receiverContact,
    required this.trackingCode,
    this.publicId,
    required this.status,
    required this.senderName,
    this.senderPhone,
    this.senderAddress,
    this.senderCity,
    this.senderCountry,
    required this.receiverName,
    this.receiverPhone,
    this.receiverAddress,
    this.receiverCity,
    this.receiverCountry,
    this.novaPostNumber,
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
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    // Support both nested (API v1) and flat structures
    final sender = json['sender'] as Map<String, dynamic>?;
    final receiver = json['receiver'] as Map<String, dynamic>?;
    final dimensions = json['dimensions'] as Map<String, dynamic>?;
    final ocr = json['ocr'] as Map<String, dynamic>?;
    final routeJson = json['route'] as Map<String, dynamic>?;
    final imagesJson = json['images'] as List<dynamic>?;
    final senderContactJson = json['sender_contact'] as Map<String, dynamic>?;
    final receiverContactJson =
        json['receiver_contact'] as Map<String, dynamic>?;

    return PackageModel(
      id: json['id'].toString(),
      routeId: json['route_id']?.toString(),
      tripId: json['trip_id']?.toString(),
      senderContactId: json['sender_contact_id']?.toString(),
      receiverContactId: json['receiver_contact_id']?.toString(),
      route: routeJson != null ? RouteInfo.fromJson(routeJson) : null,
      senderContact: senderContactJson != null
          ? ContactInfo.fromJson(senderContactJson)
          : null,
      receiverContact: receiverContactJson != null
          ? ContactInfo.fromJson(receiverContactJson)
          : null,
      trackingCode: json['tracking_code'],
      publicId: json['public_id']?.toString(),
      status: PackageStatus.fromString(json['status']),
      senderName: sender?['name'] ?? json['sender_name'] ?? '',
      senderPhone: sender?['phone'] ?? json['sender_phone'],
      senderAddress: sender?['address'] ?? json['sender_address'],
      senderCity: sender?['city'] ?? json['sender_city'],
      senderCountry: sender?['country'] ?? json['sender_country'],
      receiverName: receiver?['name'] ?? json['receiver_name'] ?? '',
      receiverPhone: receiver?['phone'] ?? json['receiver_phone'],
      receiverAddress: receiver?['address'] ?? json['receiver_address'],
      receiverCity: receiver?['city'] ?? json['receiver_city'],
      receiverCountry: receiver?['country'] ?? json['receiver_country'],
      novaPostNumber: receiver?['nova_post_number'] ?? json['nova_post_number'],
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
      images:
          imagesJson?.map((img) => PackageImage.fromJson(img)).toList() ?? [],
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
      'trip_id': tripId,
      'sender_contact_id': senderContactId,
      'receiver_contact_id': receiverContactId,
      'tracking_code': trackingCode,
      'public_id': publicId,
      'status': status.apiValue,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'sender_address': senderAddress,
      'sender_city': senderCity,
      'sender_country': senderCountry,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'receiver_address': receiverAddress,
      'receiver_city': receiverCity,
      'receiver_country': receiverCountry,
      'nova_post_number': novaPostNumber,
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
    String? id,
    String? routeId,
    String? tripId,
    String? senderContactId,
    String? receiverContactId,
    RouteInfo? route,
    ContactInfo? senderContact,
    ContactInfo? receiverContact,
    String? trackingCode,
    String? publicId,
    PackageStatus? status,
    String? senderName,
    String? senderPhone,
    String? senderAddress,
    String? senderCity,
    String? senderCountry,
    String? receiverName,
    String? receiverPhone,
    String? receiverAddress,
    String? receiverCity,
    String? receiverCountry,
    String? novaPostNumber,
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
    List<PackageImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      tripId: tripId ?? this.tripId,
      senderContactId: senderContactId ?? this.senderContactId,
      receiverContactId: receiverContactId ?? this.receiverContactId,
      route: route ?? this.route,
      senderContact: senderContact ?? this.senderContact,
      receiverContact: receiverContact ?? this.receiverContact,
      trackingCode: trackingCode ?? this.trackingCode,
      publicId: publicId ?? this.publicId,
      status: status ?? this.status,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      senderAddress: senderAddress ?? this.senderAddress,
      senderCity: senderCity ?? this.senderCity,
      senderCountry: senderCountry ?? this.senderCountry,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      receiverCity: receiverCity ?? this.receiverCity,
      receiverCountry: receiverCountry ?? this.receiverCountry,
      novaPostNumber: novaPostNumber ?? this.novaPostNumber,
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
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
