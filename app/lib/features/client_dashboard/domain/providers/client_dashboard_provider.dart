import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/client_stats_model.dart';

final clientStatsProvider = FutureProvider<ClientStats>((ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    final response = await apiService.get('/packages/client-stats');
    return ClientStats.fromJson(response.data['data']);
  } catch (e) {
    return ClientStats.empty();
  }
});
