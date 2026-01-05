import '../../../../core/services/api_service.dart';
import '../models/package_model.dart';

class PackageRepository {
  final ApiService _api;

  PackageRepository(this._api);

  Future<List<PackageModel>> getPackages({
    PackageStatus? status,
    int? routeId,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.apiValue;
    if (routeId != null) queryParams['route_id'] = routeId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _api.get('/packages', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => PackageModel.fromJson(json)).toList();
  }

  Future<PackageModel> getPackage(int id) async {
    final response = await _api.get('/packages/$id');
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data);
  }

  Future<PackageModel> createPackage({
    int? routeId,
    required String senderName,
    String? senderPhone,
    String? senderAddress,
    required String receiverName,
    String? receiverPhone,
    String? receiverAddress,
    String? description,
    double? weight,
    double? declaredValue,
    String? notes,
  }) async {
    final response = await _api.post('/packages', data: {
      if (routeId != null) 'route_id': routeId,
      'sender_name': senderName,
      if (senderPhone != null) 'sender_phone': senderPhone,
      if (senderAddress != null) 'sender_address': senderAddress,
      'receiver_name': receiverName,
      if (receiverPhone != null) 'receiver_phone': receiverPhone,
      if (receiverAddress != null) 'receiver_address': receiverAddress,
      if (description != null) 'description': description,
      if (weight != null) 'weight': weight,
      if (declaredValue != null) 'declared_value': declaredValue,
      if (notes != null) 'notes': notes,
    });
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data);
  }

  Future<PackageModel> updatePackage(int id, Map<String, dynamic> data) async {
    final response = await _api.put('/packages/$id', data: data);
    final responseData = response.data['data'] ?? response.data;
    return PackageModel.fromJson(responseData);
  }

  Future<PackageModel> updateStatus(int id, PackageStatus status, {String? notes}) async {
    final response = await _api.patch('/packages/$id/status', data: {
      'status': status.apiValue,
      if (notes != null) 'notes': notes,
    });
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data);
  }

  Future<void> deletePackage(int id) async {
    await _api.delete('/packages/$id');
  }

  Future<List<Map<String, dynamic>>> getStatusHistory(int id) async {
    final response = await _api.get('/packages/$id/history');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }
}
