class RejectionInfoModel {
  final String? rejectionReason;
  final DateTime rejectedAt;
  final bool hasAppealed;
  final DateTime? appealedAt;

  RejectionInfoModel({
    this.rejectionReason,
    required this.rejectedAt,
    required this.hasAppealed,
    this.appealedAt,
  });

  factory RejectionInfoModel.fromJson(Map<String, dynamic> json) {
    return RejectionInfoModel(
      rejectionReason: json['rejection_reason'],
      rejectedAt: DateTime.parse(json['rejected_at']),
      hasAppealed: json['has_appealed'] ?? false,
      appealedAt: json['appealed_at'] != null
          ? DateTime.parse(json['appealed_at'])
          : null,
    );
  }
}
