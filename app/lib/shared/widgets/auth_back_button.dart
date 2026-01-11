import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Boton de retroceso estilizado para pantallas de autenticacion.
/// Usa un contenedor blanco con sombra suave.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            boxShadow: AppTheme.shadowSoft,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.lightTextPrimary,
            size: 20,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
