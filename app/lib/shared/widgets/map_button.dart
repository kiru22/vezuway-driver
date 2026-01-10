import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../l10n/l10n_extension.dart';

/// Variantes visuales del botón de mapa.
enum MapButtonStyle {
  /// Estilo con fondo de superficie y borde (para tarjetas).
  outlined,

  /// Estilo con fondo primary tenue (para pantallas de detalle).
  filled,
}

/// Botón para abrir ubicación en mapa.
///
/// Uso:
/// ```dart
/// MapButton(onTap: () => openMaps(address))
/// MapButton(onTap: () => openMaps(address), style: MapButtonStyle.outlined)
/// ```
class MapButton extends StatelessWidget {
  final VoidCallback onTap;
  final MapButtonStyle style;

  const MapButton({
    super.key,
    required this.onTap,
    this.style = MapButtonStyle.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: switch (style) {
        MapButtonStyle.outlined => _buildOutlined(context),
        MapButtonStyle.filled => _buildFilled(context),
      },
    );
  }

  Widget _buildOutlined(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.l10n.action_openMap,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilled(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            context.l10n.action_viewOnMap,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
