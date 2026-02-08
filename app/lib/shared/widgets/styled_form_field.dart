import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/theme_extensions.dart';

/// A styled text form field with consistent theming for dark/light modes.
///
/// Provides elevation shadow in light mode, proper border colors,
/// and a clean, modern appearance across the app.
class StyledFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final bool dense;

  const StyledFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.prefixWidget,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.textInputAction,
    this.onEditingComplete,
    this.dense = false,
  });

  Widget? _buildPrefixIcon(bool isDark, AppColorsExtension colors) {
    if (prefixWidget != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: prefixWidget,
      );
    }
    if (prefixIcon != null) {
      return Icon(
        prefixIcon,
        size: 20,
        color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final radius = BorderRadius.circular(12);
    final borderColor = isDark ? colors.border : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        maxLines: maxLines,
        enabled: enabled,
        onChanged: onChanged,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: isDark ? colors.textMuted : AppColors.lightTextMuted,
          ),
          prefixIcon: _buildPrefixIcon(isDark, colors),
          prefixIconConstraints: prefixWidget != null
              ? const BoxConstraints(minWidth: 44, minHeight: 44)
              : null,
          suffix: suffix,
          filled: true,
          fillColor: isDark ? colors.surface : Colors.white,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 12 : 16),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: borderColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
