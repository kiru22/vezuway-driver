import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/theme_extensions.dart';
import '../../l10n/l10n_extension.dart';
import 'bottom_sheet_handle.dart';
import 'source_picker_option.dart';

/// Muestra un bottom sheet para seleccionar la fuente de imagen (cámara/galería).
/// Retorna [ImageSource.camera], [ImageSource.gallery], o null si se cancela.
///
/// Uso:
/// ```dart
/// final source = await showImageSourcePicker(context);
/// if (source != null) {
///   // Usar la fuente seleccionada
/// }
/// ```
Future<ImageSource?> showImageSourcePicker(BuildContext context) {
  final colors = context.colors;
  final isDark = context.isDarkMode;

  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: isDark ? colors.surface : Colors.white,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: 16),
            Text(
              sheetContext.l10n.ocr_selectSource,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SourcePickerOption(
                    icon: Icons.camera_alt_outlined,
                    label: sheetContext.l10n.ocr_camera,
                    onTap: () =>
                        Navigator.pop(sheetContext, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SourcePickerOption(
                    icon: Icons.photo_library_outlined,
                    label: sheetContext.l10n.ocr_gallery,
                    onTap: () =>
                        Navigator.pop(sheetContext, ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
