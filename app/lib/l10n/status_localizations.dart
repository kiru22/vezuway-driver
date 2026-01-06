import 'package:flutter/widgets.dart';
import '../generated/l10n/app_localizations.dart';
import '../features/packages/data/models/package_model.dart';
import '../features/routes/data/models/route_model.dart';
import '../shared/widgets/status_chip.dart';

/// Extension to get localized display names for PackageStatus.
///
/// Usage:
/// ```dart
/// Text(package.status.localizedName(context))
/// ```
extension PackageStatusL10n on PackageStatus {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PackageStatus.pending:
        return l10n.status_package_pending;
      case PackageStatus.pickedUp:
        return l10n.status_package_pickedUp;
      case PackageStatus.inTransit:
        return l10n.status_package_inTransit;
      case PackageStatus.inWarehouse:
        return l10n.status_package_inWarehouse;
      case PackageStatus.outForDelivery:
        return l10n.status_package_outForDelivery;
      case PackageStatus.delivered:
        return l10n.status_package_delivered;
      case PackageStatus.cancelled:
        return l10n.status_package_cancelled;
      case PackageStatus.returned:
        return l10n.status_package_returned;
    }
  }
}

/// Extension to get localized display names for RouteStatus.
///
/// Usage:
/// ```dart
/// Text(route.status.localizedName(context))
/// ```
extension RouteStatusL10n on RouteStatus {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case RouteStatus.planned:
        return l10n.status_route_planned;
      case RouteStatus.inProgress:
        return l10n.status_route_inProgress;
      case RouteStatus.completed:
        return l10n.status_route_completed;
      case RouteStatus.cancelled:
        return l10n.status_route_cancelled;
    }
  }

  ChipVariant get chipVariant {
    switch (this) {
      case RouteStatus.planned:
        return ChipVariant.blue;
      case RouteStatus.inProgress:
        return ChipVariant.orange;
      case RouteStatus.completed:
        return ChipVariant.green;
      case RouteStatus.cancelled:
        return ChipVariant.gray;
    }
  }
}
