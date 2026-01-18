import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/image_source_picker.dart';

/// Botón para añadir imágenes a un paquete.
/// Abre un picker para seleccionar desde cámara o galería.
class AddImageButton extends StatefulWidget {
  /// Callback cuando se selecciona una imagen
  final void Function(Uint8List imageBytes) onImageSelected;

  /// Si el botón está en estado de carga
  final bool isLoading;

  /// Si se muestra como botón compacto (tile) o expandido
  final bool compact;

  const AddImageButton({
    super.key,
    required this.onImageSelected,
    this.isLoading = false,
    this.compact = false,
  });

  @override
  State<AddImageButton> createState() => _AddImageButtonState();
}

class _AddImageButtonState extends State<AddImageButton> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final isLoading = widget.isLoading || _isPicking;

    if (widget.compact) {
      return _buildCompactButton(colors, isDark, isLoading);
    }

    return _buildExpandedButton(colors, isDark, isLoading);
  }

  Widget _buildCompactButton(
    dynamic colors,
    bool isDark,
    bool isLoading,
  ) {
    return GestureDetector(
      onTap: isLoading ? null : () => _showSourcePicker(context),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? colors.surface : AppColors.lightInputBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.packages_addImage,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildExpandedButton(
    dynamic colors,
    bool isDark,
    bool isLoading,
  ) {
    return TextButton.icon(
      onPressed: isLoading ? null : () => _showSourcePicker(context),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primary,
              size: 20,
            ),
      label: Text(
        context.l10n.packages_addImage,
        style: TextStyle(
          color: isLoading
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _showSourcePicker(BuildContext context) async {
    final source = await showImageSourcePicker(context);
    if (source != null) {
      _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;

    setState(() => _isPicking = true);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        widget.onImageSelected(bytes);
      }
    } catch (e) {
      debugPrint('AddImageButton error picking image: $e');
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }
}

