import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/packages/data/models/package_model.dart';
import '../../l10n/status_localizations.dart';
import '../extensions/package_status_extensions.dart';

/// Variantes de tamaño para StatusBadge.
enum StatusBadgeSize {
  /// Versión compacta para tarjetas: sin icono, texto en mayúsculas.
  compact,

  /// Versión regular para pantallas de detalle: con icono y sombra.
  regular,
}

/// Badge de estado reutilizable para paquetes.
///
/// Uso:
/// ```dart
/// // En tarjetas (compacto)
/// StatusBadge(status: package.status, size: StatusBadgeSize.compact)
///
/// // En pantallas de detalle (regular)
/// StatusBadge(status: package.status)
/// ```
class StatusBadge extends StatelessWidget {
  final PackageStatus status;
  final StatusBadgeSize size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return switch (size) {
      StatusBadgeSize.compact => _buildCompact(context, color),
      StatusBadgeSize.regular => _buildRegular(context, color),
    };
  }

  Widget _buildCompact(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.localizedName(context).toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildRegular(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.localizedName(context),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
