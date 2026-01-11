import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/packages/data/models/package_model.dart';

/// Extension que añade propiedades de UI a PackageStatus.
///
/// Uso:
/// ```dart
/// final color = package.status.color;
/// final icon = package.status.icon;
/// final next = package.status.nextStatus;
/// ```
extension PackageStatusUI on PackageStatus {
  /// Color asociado al estado del paquete.
  Color get color {
    return switch (this) {
      PackageStatus.registered => AppColors.chipGrayText, // Сірий
      PackageStatus.inTransit => AppColors.warning, // Жовтий
      PackageStatus.delivered => AppColors.success, // Зелений
      PackageStatus.delayed => AppColors.error, // Червоний
    };
  }

  /// Icono asociado al estado del paquete.
  IconData get icon {
    return switch (this) {
      PackageStatus.registered => Icons.fact_check_outlined,
      PackageStatus.inTransit => Icons.local_shipping_outlined,
      PackageStatus.delivered => Icons.check_circle_outline,
      PackageStatus.delayed => Icons.warning_amber_outlined,
    };
  }

  /// Siguiente estado lógico en el flujo de trabajo.
  /// Retorna null si no hay siguiente estado (ej: delivered).
  PackageStatus? get nextStatus {
    return switch (this) {
      PackageStatus.registered => PackageStatus.inTransit,
      PackageStatus.inTransit => PackageStatus.delivered,
      PackageStatus.delivered => null,
      PackageStatus.delayed => PackageStatus.delivered,
    };
  }
}
