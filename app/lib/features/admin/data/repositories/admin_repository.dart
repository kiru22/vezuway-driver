import '../../../../core/services/api_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/pending_driver_model.dart';

class AdminRepository {
  final ApiService _api;

  AdminRepository(this._api);

  Future<List<UserModel>> getAllUsers({String? roleFilter}) async {
    final response = await _api.get(
      '/admin/users',
      queryParameters: roleFilter != null ? {'role': roleFilter} : null,
    );
    return _extractList(response.data)
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<PendingDriverModel>> getPendingDrivers() async {
    final response = await _api.get('/admin/drivers/pending');
    return _extractList(response.data)
        .map((json) => PendingDriverModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> approveDriver(String userId) async {
    final response = await _api.post('/admin/drivers/$userId/approve');
    return UserModel.fromJson(_extractData(response.data));
  }

  Future<UserModel> rejectDriver(String userId, {String? reason}) async {
    final response = await _api.post('/admin/drivers/$userId/reject', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    return UserModel.fromJson(_extractData(response.data));
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is Map) {
      return (responseData['data'] as List<dynamic>?) ?? [];
    }
    return responseData as List<dynamic>;
  }

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'] as Map<String, dynamic>;
    }
    return responseData as Map<String, dynamic>;
  }
}
