import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../models/package_model.dart';

class PackageRepository {
  final ApiService _api;

  PackageRepository(this._api);

  Future<List<PackageModel>> getPackages({
    PackageStatus? status,
    String? tripId,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status.apiValue;
    if (tripId != null) queryParams['trip_id'] = tripId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    try {
      final response =
          await _api.get('/packages', queryParameters: queryParams);
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => PackageModel.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('PackageRepository.getPackages error: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  Future<PackageModel> getPackage(String id) async {
    final response = await _api.get('/packages/$id');
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data);
  }

  Future<PackageModel> createPackage({
    String? tripId,
    String? senderContactId,
    String? receiverContactId,
    String? senderName,
    String? senderPhone,
    String? senderCity,
    String? senderAddress,
    required String receiverName,
    String? receiverPhone,
    String? receiverCity,
    String? receiverAddress,
    double? weight,
    int? lengthCm,
    int? widthCm,
    int? heightCm,
    int? quantity,
    double? declaredValue,
    List<Uint8List>? images,
  }) async {
    // Build FormData for multipart request
    final formData = FormData.fromMap({
      if (tripId != null) 'trip_id': tripId,
      if (senderContactId != null) 'sender_contact_id': senderContactId,
      if (receiverContactId != null) 'receiver_contact_id': receiverContactId,
      if (senderName != null && senderName.isNotEmpty)
        'sender_name': senderName,
      if (senderPhone != null && senderPhone.isNotEmpty)
        'sender_phone': senderPhone,
      if (senderCity != null && senderCity.isNotEmpty)
        'sender_city': senderCity,
      if (senderAddress != null && senderAddress.isNotEmpty)
        'sender_address': senderAddress,
      'receiver_name': receiverName,
      if (receiverPhone != null) 'receiver_phone': receiverPhone,
      if (receiverCity != null && receiverCity.isNotEmpty)
        'receiver_city': receiverCity,
      if (receiverAddress != null) 'receiver_address': receiverAddress,
      if (weight != null) 'weight_kg': weight,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (widthCm != null) 'width_cm': widthCm,
      if (heightCm != null) 'height_cm': heightCm,
      if (quantity != null) 'quantity': quantity,
      if (declaredValue != null) 'declared_value': declaredValue,
    });

    // Add images if provided
    if (images != null && images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
        formData.files.add(MapEntry(
          'images[]',
          MultipartFile.fromBytes(
            images[i],
            filename: 'image_$i.jpg',
          ),
        ));
      }
    }

    final response = await _api.post('/packages', data: formData);
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data);
  }

  Future<PackageModel> updatePackage(
      String id, Map<String, dynamic> data) async {
    final response = await _api.put('/packages/$id', data: data);
    final responseData = response.data['data'] ?? response.data;
    return PackageModel.fromJson(responseData);
  }

  Future<PackageModel> updateStatus(String id, PackageStatus status,
      {String? notes}) async {
    final response = await _api.patch('/packages/$id/status', data: {
      'status': status.apiValue,
      if (notes != null) 'notes': notes,
    });
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data);
  }

  Future<void> deletePackage(String id) async {
    await _api.delete('/packages/$id');
  }

  Future<List<Map<String, dynamic>>> getStatusHistory(String id) async {
    final response = await _api.get('/packages/$id/history');
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.cast<Map<String, dynamic>>();
  }

  /// Añade imágenes a un paquete existente
  Future<List<PackageImage>> addImages(
      String packageId, List<Uint8List> images) async {
    final formData = FormData();

    for (var i = 0; i < images.length; i++) {
      formData.files.add(MapEntry(
        'images[]',
        MultipartFile.fromBytes(
          images[i],
          filename: 'image_$i.jpg',
        ),
      ));
    }

    final response =
        await _api.post('/packages/$packageId/images', data: formData);
    final List<dynamic> imagesData = response.data['images'] ?? [];
    return imagesData.map((img) => PackageImage.fromJson(img)).toList();
  }

  /// Elimina una imagen de un paquete
  Future<void> deleteImage(String packageId, String mediaId) async {
    await _api.delete('/packages/$packageId/images/$mediaId');
  }

  /// Obtiene el conteo de paquetes por estado
  Future<Map<String, int>> getPackageCounts() async {
    final response = await _api.get('/packages/counts');
    final data = response.data['data'] as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, _toInt(value)));
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Actualiza el estado de múltiples paquetes en una sola llamada
  Future<({String message, int updatedCount})> bulkUpdateStatus({
    required List<String> packageIds,
    required PackageStatus status,
    String? notes,
  }) async {
    final response = await _api.post('/packages/bulk-status', data: {
      'package_ids': packageIds,
      'status': status.apiValue,
      if (notes != null) 'notes': notes,
    });
    return (
      message: response.data['message']?.toString() ?? '',
      updatedCount: response.data['updated_count'] as int? ?? 0,
    );
  }
}
