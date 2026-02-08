import '../../../../core/services/api_service.dart';
import '../models/plan_request_model.dart';

class PlanRequestRepository {
  final ApiService _api;

  PlanRequestRepository(this._api);

  Future<PlanRequestModel> createPlanRequest({
    required String planKey,
    required String planName,
    required int planPrice,
  }) async {
    final response = await _api.post('/plan-requests', data: {
      'plan_key': planKey,
      'plan_name': planName,
      'plan_price': planPrice,
    });
    final data = response.data['data'] ?? response.data;
    return PlanRequestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PlanRequestModel?> getMyRequest() async {
    final response = await _api.get('/plan-requests/mine');
    final data = response.data['data'];
    if (data == null) return null;
    return PlanRequestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PlanRequestModel>> getPlanRequests() async {
    final response = await _api.get('/admin/plan-requests');
    final list = _extractList(response.data);
    return list
        .map((json) => PlanRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is Map) {
      return (responseData['data'] as List<dynamic>?) ?? [];
    }
    return responseData as List<dynamic>;
  }
}
