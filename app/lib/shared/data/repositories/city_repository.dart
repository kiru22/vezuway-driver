import '../../../core/services/api_service.dart';
import '../../models/city_model.dart';

class CityRepository {
  final ApiService _apiService;

  CityRepository(this._apiService);

  Future<List<CityModel>> searchCities({
    required String query,
    List<String>? countries,
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final queryParams = <String, dynamic>{
      'q': query,
      'limit': limit,
    };

    if (countries != null && countries.isNotEmpty) {
      queryParams['countries'] = countries.join(',');
    }

    final response = await _apiService.get(
      '/cities/search',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as List;
    return data.map((json) => CityModel.fromApiJson(json)).toList();
  }
}
