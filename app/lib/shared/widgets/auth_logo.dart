import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Logo de la app "vezuway." con ícono de camión gradiente.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícono de camión con gradiente
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.loginButtonGradient.createShader(bounds),
          child: const Icon(
            Icons.local_shipping,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        // Texto "vezuway."
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
            children: [
              const TextSpan(text: 'vezuway'),
              TextSpan(
                text: '.',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
