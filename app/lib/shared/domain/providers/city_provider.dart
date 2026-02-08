import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/domain/providers/auth_provider.dart';
import '../../data/repositories/city_repository.dart';
import '../../models/city_model.dart';

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return CityRepository(apiService);
});

class CitySearchParams {
  final String query;
  final List<String>? countries;

  const CitySearchParams({required this.query, this.countries});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CitySearchParams &&
          query == other.query &&
          _listEquals(countries, other.countries);

  @override
  int get hashCode => query.hashCode ^ (countries?.join(',').hashCode ?? 0);

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

final citySearchProvider =
    FutureProvider.family<List<CityModel>, CitySearchParams>(
        (ref, params) async {
  if (params.query.length < 2) return [];

  final repository = ref.read(cityRepositoryProvider);
  return repository.searchCities(
    query: params.query,
    countries: params.countries,
  );
});
