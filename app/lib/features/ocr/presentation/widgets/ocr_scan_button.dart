import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/image_source_picker.dart';
import '../../domain/providers/ocr_provider.dart';
import 'ocr_result_sheet.dart';

class OcrScanButton extends ConsumerStatefulWidget {
  /// Callback cuando se aplican los datos del OCR.
  /// Ahora incluye los bytes de la imagen para guardarla en la galería.
  final void Function(String? name, String? phone, String? city, Uint8List? imageBytes) onApply;

  const OcrScanButton({
    super.key,
    required this.onApply,
  });

  @override
  ConsumerState<OcrScanButton> createState() => _OcrScanButtonState();
}

class _OcrScanButtonState extends ConsumerState<OcrScanButton> {
  bool _isShowingSheet = false;

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de estado para mostrar el result sheet
    ref.listen<OcrState>(ocrProvider, (previous, next) {
      if (!_isShowingSheet &&
          (next.status == OcrStatus.success || next.status == OcrStatus.error) &&
          previous?.status == OcrStatus.processing) {
        _showResultSheet(context);
      }
    });

    final ocrState = ref.watch(ocrProvider);
    final isProcessing = ocrState.status == OcrStatus.picking ||
        ocrState.status == OcrStatus.processing;

    return SizedBox(
      height: 40,
      child: TextButton.icon(
        onPressed: isProcessing ? null : () => _showSourcePicker(context),
        icon: isProcessing
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : const Icon(
                Icons.document_scanner_outlined,
                color: AppColors.primary,
                size: 18,
              ),
        label: Text(
          context.l10n.ocr_scanButton,
          style: TextStyle(
            color: isProcessing ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _showSourcePicker(BuildContext context) async {
    final source = await showImageSourcePicker(context);
    if (source != null) {
      _startScan(fromCamera: source == ImageSource.camera);
    }
  }

  void _startScan({required bool fromCamera}) {
    final notifier = ref.read(ocrProvider.notifier);

    if (fromCamera) {
      notifier.pickAndScanFromCamera();
    } else {
      notifier.pickAndScanFromGallery();
    }
    // El ref.listen en build() se encargará de mostrar el sheet cuando termine
  }

  void _showResultSheet(BuildContext context) {
    if (!context.mounted) return;

    _isShowingSheet = true;
    final ocrState = ref.read(ocrProvider);
    final imageBytes = ocrState.imageBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => OcrResultSheet(
        onApply: (name, phone, city) {
          Navigator.pop(sheetContext);
          widget.onApply(name, phone, city, imageBytes);
          ref.read(ocrProvider.notifier).reset();
        },
        onCancel: () {
          Navigator.pop(sheetContext);
          ref.read(ocrProvider.notifier).reset();
        },
      ),
    ).whenComplete(() {
      _isShowingSheet = false;
    });
  }
}

