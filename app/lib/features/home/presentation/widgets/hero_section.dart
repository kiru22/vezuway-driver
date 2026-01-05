import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

class HeroSection extends StatelessWidget {
  final String? userName;

  const HeroSection({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM', 'es');
    final formattedDate = dateFormat.format(now);
    final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting with gradient effect
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [colors.textPrimary, colors.textSecondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'Hola, ${userName ?? 'Usuario'}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              capitalizedDate,
              style: TextStyle(
                fontSize: 15,
                color: colors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
