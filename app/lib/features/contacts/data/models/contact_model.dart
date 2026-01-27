int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

class ContactModel {
  final String id;
  final String? userId;
  final String createdByUserId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final bool isVerified;
  final DateTime? lastPackageAt;
  final int totalPackagesSent;
  final int totalPackagesReceived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContactModel({
    required this.id,
    this.userId,
    required this.createdByUserId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.notes,
    this.metadata,
    required this.isVerified,
    this.lastPackageAt,
    required this.totalPackagesSent,
    required this.totalPackagesReceived,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total de paquetes (enviados + recibidos)
  int get totalPackages => totalPackagesSent + totalPackagesReceived;

  /// Dirección completa formateada
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Iniciales del nombre (para avatar)
  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  /// Email o teléfono para mostrar (fallback)
  String? get emailOrPhone => email ?? phone;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      createdByUserId: json['created_by_user_id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isVerified: json['is_verified'] as bool? ?? false,
      lastPackageAt: json['last_package_at'] != null
          ? DateTime.parse(json['last_package_at'] as String)
          : null,
      totalPackagesSent: _toInt(json['total_packages_sent']),
      totalPackagesReceived: _toInt(json['total_packages_received']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'created_by_user_id': createdByUserId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'metadata': metadata,
      'is_verified': isVerified,
      'last_package_at': lastPackageAt?.toIso8601String(),
      'total_packages_sent': totalPackagesSent,
      'total_packages_received': totalPackagesReceived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ContactModel copyWith({
    String? id,
    String? userId,
    String? createdByUserId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? notes,
    Map<String, dynamic>? metadata,
    bool? isVerified,
    DateTime? lastPackageAt,
    int? totalPackagesSent,
    int? totalPackagesReceived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      isVerified: isVerified ?? this.isVerified,
      lastPackageAt: lastPackageAt ?? this.lastPackageAt,
      totalPackagesSent: totalPackagesSent ?? this.totalPackagesSent,
      totalPackagesReceived:
          totalPackagesReceived ?? this.totalPackagesReceived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
