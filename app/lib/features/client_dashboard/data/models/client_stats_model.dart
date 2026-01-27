class ClientStats {
  final int total;
  final int pending;
  final int inTransit;
  final int delivered;
  final int delayed;
  final double totalWeight;
  final double totalDeclaredValue;

  const ClientStats({
    required this.total,
    required this.pending,
    required this.inTransit,
    required this.delivered,
    required this.delayed,
    required this.totalWeight,
    required this.totalDeclaredValue,
  });

  factory ClientStats.fromJson(Map<String, dynamic> json) {
    return ClientStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      inTransit: json['in_transit'] ?? 0,
      delivered: json['delivered'] ?? 0,
      delayed: json['delayed'] ?? 0,
      totalWeight: (json['total_weight'] ?? 0).toDouble(),
      totalDeclaredValue: (json['total_declared_value'] ?? 0).toDouble(),
    );
  }

  factory ClientStats.empty() => const ClientStats(
        total: 0,
        pending: 0,
        inTransit: 0,
        delivered: 0,
        delayed: 0,
        totalWeight: 0,
        totalDeclaredValue: 0,
      );
}
