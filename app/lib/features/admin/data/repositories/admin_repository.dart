import '../../../../core/services/api_service.dart';
import '../../../auth/data/models/user_model.dart';

class AdminRepository {
  final ApiService _api;

  AdminRepository(this._api);

  Future<List<UserModel>> getAllUsers({String? roleFilter}) async {
    final queryParams = <String, dynamic>{};
    if (roleFilter != null) {
      queryParams['role'] = roleFilter;
    }

    final response = await _api.get(
      '/admin/users',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final responseData = response.data;
    final List<dynamic> data =
        responseData is Map ? (responseData['data'] ?? []) : responseData;
    return data
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserModel>> getPendingDrivers() async {
    final response = await _api.get('/admin/drivers/pending');
    final responseData = response.data;
    final List<dynamic> data =
        responseData is Map ? (responseData['data'] ?? []) : responseData;
    return data
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> approveDriver(String userId) async {
    final response = await _api.post('/admin/drivers/$userId/approve');
    final responseData = response.data;
    final userData =
        responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }

  Future<UserModel> rejectDriver(String userId, {String? reason}) async {
    final response = await _api.post('/admin/drivers/$userId/reject', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    final responseData = response.data;
    final userData =
        responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;
    return UserModel.fromJson(userData as Map<String, dynamic>);
  }
}
