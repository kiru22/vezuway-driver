import '../../../../shared/enums/driver_status.dart';
import '../../../auth/data/models/user_model.dart';

class PendingDriverModel extends UserModel {
  final bool isReapplication;
  final String? previousRejectionReason;
  final String? appealText;

  PendingDriverModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.locale,
    required super.themePreference,
    super.avatarUrl,
    super.fcmToken,
    super.googleId,
    super.role,
    super.driverStatus,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    this.isReapplication = false,
    this.previousRejectionReason,
    this.appealText,
  });

  factory PendingDriverModel.fromJson(Map<String, dynamic> json) {
    return PendingDriverModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      locale: json['locale'] ?? 'es',
      themePreference: json['theme_preference'] ?? 'dark',
      avatarUrl: json['avatar_url'],
      fcmToken: json['fcm_token'],
      googleId: json['google_id'],
      role: json['role'],
      driverStatus: DriverStatus.fromString(json['driver_status']),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isReapplication: json['is_reapplication'] ?? false,
      previousRejectionReason: json['previous_rejection_reason'],
      appealText: json['appeal_text'],
    );
  }
}
