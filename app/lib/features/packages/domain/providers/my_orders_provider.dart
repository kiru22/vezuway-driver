import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/package_model.dart';

/// Provider para obtener los pedidos del usuario actual (como contacto).
/// Retorna lista vacía si el usuario no tiene contacto vinculado.
final myOrdersProvider = FutureProvider<List<PackageModel>>((ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    final response = await apiService.get('/packages/my-orders');
    final data = response.data['data'] as List;
    return data.map((json) => PackageModel.fromJson(json)).toList();
  } catch (e) {
    // Si el usuario no tiene contacto vinculado, devolver lista vacía
    return [];
  }
});
