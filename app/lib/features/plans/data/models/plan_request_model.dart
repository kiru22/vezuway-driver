class PlanRequestModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String planKey;
  final String planName;
  final int planPrice;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PlanRequestModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.planKey,
    required this.planName,
    required this.planPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory PlanRequestModel.fromJson(Map<String, dynamic> json) {
    return PlanRequestModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      planKey: json['plan_key'] as String,
      planName: json['plan_name'] as String,
      planPrice: json['plan_price'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
