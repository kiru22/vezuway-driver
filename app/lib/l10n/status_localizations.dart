import 'package:flutter/widgets.dart';
import '../generated/l10n/app_localizations.dart';
import '../features/packages/data/models/package_model.dart';
import '../features/trips/data/models/trip_status.dart';
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
      case PackageStatus.registered:
        return l10n.status_package_registered;
      case PackageStatus.inTransit:
        return l10n.status_package_inTransit;
      case PackageStatus.delivered:
        return l10n.status_package_delivered;
      case PackageStatus.delayed:
        return l10n.status_package_delayed;
    }
  }

  String localizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PackageStatus.registered:
        return l10n.status_package_registered_desc;
      case PackageStatus.inTransit:
        return l10n.status_package_inTransit_desc;
      case PackageStatus.delivered:
        return l10n.status_package_delivered_desc;
      case PackageStatus.delayed:
        return l10n.status_package_delayed_desc;
    }
  }
}

/// Extension to get localized display names for TripStatus.
///
/// Usage:
/// ```dart
/// Text(trip.status.localizedName(context))
/// ```
extension TripStatusL10n on TripStatus {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case TripStatus.planned:
        return l10n.status_route_planned;
      case TripStatus.inProgress:
        return l10n.status_route_inProgress;
      case TripStatus.completed:
        return l10n.status_route_completed;
      case TripStatus.cancelled:
        return l10n.status_route_cancelled;
    }
  }

  ChipVariant get chipVariant {
    switch (this) {
      case TripStatus.planned:
        return ChipVariant.blue;
      case TripStatus.inProgress:
        return ChipVariant.orange;
      case TripStatus.completed:
        return ChipVariant.green;
      case TripStatus.cancelled:
        return ChipVariant.gray;
    }
  }
}
