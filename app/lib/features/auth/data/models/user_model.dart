class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String locale;
  final String themePreference;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.locale,
    required this.themePreference,
    this.avatarUrl,
    this.fcmToken,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      locale: json['locale'] ?? 'es',
      themePreference: json['theme_preference'] ?? 'dark',
      avatarUrl: json['avatar_url'],
      fcmToken: json['fcm_token'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'locale': locale,
      'theme_preference': themePreference,
      'avatar_url': avatarUrl,
      'fcm_token': fcmToken,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? locale,
    String? themePreference,
    String? avatarUrl,
    String? fcmToken,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      locale: locale ?? this.locale,
      themePreference: themePreference ?? this.themePreference,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
