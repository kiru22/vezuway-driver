import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Enlace de navegacion para pantallas de autenticacion.
/// Muestra texto secundario con un enlace primario clicable.
class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
