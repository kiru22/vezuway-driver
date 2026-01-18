import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../domain/providers/ocr_provider.dart';

class OcrResultSheet extends ConsumerStatefulWidget {
  final void Function(String? name, String? phone, String? city) onApply;
  final VoidCallback onCancel;

  const OcrResultSheet({
    super.key,
    required this.onApply,
    required this.onCancel,
  });

  @override
  ConsumerState<OcrResultSheet> createState() => _OcrResultSheetState();
}

class _OcrResultSheetState extends ConsumerState<OcrResultSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(ocrProvider);
    _nameController = TextEditingController(text: state.result?.name ?? '');
    _phoneController = TextEditingController(text: state.result?.phone ?? '');
    _cityController = TextEditingController(text: state.result?.city ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocrState = ref.watch(ocrProvider);
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title with confidence badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.ocr_resultsTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (ocrState.result != null)
                    _ConfidenceBadge(confidence: ocrState.result!.confidence),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.ocr_resultsSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Image preview
              if (ocrState.imageBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    ocrState.imageBytes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Error state
              if (ocrState.status == OcrStatus.error) ...[
                _AlertBox(
                  color: AppColors.error,
                  icon: Icons.error_outline,
                  message: ocrState.error ?? context.l10n.ocr_error,
                ),
                const SizedBox(height: 20),
              ],

              // No data warning
              if (ocrState.result != null && !ocrState.result!.hasAnyData) ...[
                _AlertBox(
                  color: AppColors.warning,
                  icon: Icons.warning_amber_outlined,
                  message: context.l10n.ocr_noDataFound,
                  textColor: colors.textPrimary,
                ),
                const SizedBox(height: 20),
              ],

              // Editable fields
              _OcrTextField(
                controller: _nameController,
                label: context.l10n.packages_nameLabel,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _OcrTextField(
                controller: _phoneController,
                label: context.l10n.packages_phoneLabel,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _OcrTextField(
                controller: _cityController,
                label: context.l10n.packages_cityLabel,
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? colors.border : AppColors.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.common_cancel,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onApply(
                            _nameController.text.isNotEmpty ? _nameController.text : null,
                            _phoneController.text.isNotEmpty ? _phoneController.text : null,
                            _cityController.text.isNotEmpty ? _cityController.text : null,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.ocr_apply,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).toInt();
    final (color, icon) = _getConfidenceStyle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$percent%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getConfidenceStyle() {
    if (confidence >= 0.66) {
      return (AppColors.success, Icons.check_circle_outline);
    }
    if (confidence >= 0.33) {
      return (AppColors.warning, Icons.warning_amber_outlined);
    }
    return (AppColors.error, Icons.error_outline);
  }
}

class _AlertBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  final Color? textColor;

  const _AlertBox({
    required this.color,
    required this.icon,
    required this.message,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor ?? color),
            ),
          ),
        ],
      ),
    );
  }
}

class _OcrTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _OcrTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
          ),
          filled: true,
          fillColor: isDark ? colors.surface : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? colors.border : AppColors.lightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? colors.border : AppColors.lightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
