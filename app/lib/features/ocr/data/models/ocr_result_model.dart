class OcrResultModel {
  final String? rawText;
  final String? name;
  final String? phone;
  final String? city;
  final double confidence;

  const OcrResultModel({
    this.rawText,
    this.name,
    this.phone,
    this.city,
    this.confidence = 0,
  });

  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    final parsed = json['parsed'] as Map<String, dynamic>?;
    return OcrResultModel(
      rawText: json['raw_text'] as String?,
      name: parsed?['name'] as String?,
      phone: parsed?['phone'] as String?,
      city: parsed?['city'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  bool get hasAnyData => name != null || phone != null || city != null;

  OcrResultModel copyWith({
    String? rawText,
    String? name,
    String? phone,
    String? city,
    double? confidence,
  }) {
    return OcrResultModel(
      rawText: rawText ?? this.rawText,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      confidence: confidence ?? this.confidence,
    );
  }
}
