import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Boton para login social (Google, Apple, etc).
/// Estilo outlined con icono y texto.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.iconPath,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final String iconPath;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.lightTextMuted),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
