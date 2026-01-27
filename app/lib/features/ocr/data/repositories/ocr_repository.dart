import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';
import '../models/ocr_result_model.dart';

class OcrRepository {
  final ApiService _api;

  OcrRepository(this._api);

  Future<OcrResultModel> scanImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });
    return _sendScanRequest(formData);
  }

  Future<OcrResultModel> scanImageBytes(
      Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: filename),
    });
    return _sendScanRequest(formData);
  }

  Future<OcrResultModel> _sendScanRequest(FormData formData) async {
    final response = await _api.postMultipart('/ocr/scan', data: formData);
    final data = response.data as Map<String, dynamic>;
    return OcrResultModel.fromJson(data);
  }
}
