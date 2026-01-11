import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Divisor con texto central para pantallas de autenticacion.
/// Usado para separar metodos de login (ej: "o continua con").
class AuthDivider extends StatelessWidget {
  const AuthDivider({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.lightTextMuted.withValues(alpha: 0.4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.lightTextMuted.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
