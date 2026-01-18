import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/ocr_result_model.dart';
import '../../data/repositories/ocr_repository.dart';

// OCR Repository Provider
final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return OcrRepository(ref.read(apiServiceProvider));
});

// OCR State
enum OcrStatus { idle, picking, processing, success, error }

class OcrState {
  final OcrStatus status;
  final OcrResultModel? result;
  final String? error;
  final Uint8List? imageBytes;
  final String? imagePath;

  const OcrState({
    this.status = OcrStatus.idle,
    this.result,
    this.error,
    this.imageBytes,
    this.imagePath,
  });

  OcrState copyWith({
    OcrStatus? status,
    OcrResultModel? result,
    String? error,
    Uint8List? imageBytes,
    String? imagePath,
    bool clearResult = false,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return OcrState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    );
  }
}

// OCR Notifier
class OcrNotifier extends StateNotifier<OcrState> {
  final OcrRepository _repository;
  final ImagePicker _picker = ImagePicker();

  OcrNotifier(this._repository) : super(const OcrState());

  Future<void> pickAndScanFromCamera() async {
    await _pickAndScan(ImageSource.camera);
  }

  Future<void> pickAndScanFromGallery() async {
    await _pickAndScan(ImageSource.gallery);
  }

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      state = state.copyWith(status: OcrStatus.picking, clearError: true);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) {
        state = state.copyWith(status: OcrStatus.idle);
        return;
      }

      // Read bytes from XFile (works on both web and mobile)
      final bytes = await pickedFile.readAsBytes();
      final filename = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

      state = state.copyWith(
        status: OcrStatus.processing,
        imageBytes: bytes,
        imagePath: pickedFile.path,
      );

      final result = await _repository.scanImageBytes(bytes, filename);
      state = state.copyWith(
        status: OcrStatus.success,
        result: result,
      );
    } catch (e, stack) {
      debugPrint('OcrNotifier.pickAndScan error: $e');
      debugPrint('Stack: $stack');
      state = state.copyWith(
        status: OcrStatus.error,
        error: 'Error al procesar la imagen',
      );
    }
  }

  void updateResult(OcrResultModel result) {
    state = state.copyWith(result: result);
  }

  void reset() {
    state = const OcrState();
  }
}

// OCR Provider
final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier(ref.read(ocrRepositoryProvider));
});
