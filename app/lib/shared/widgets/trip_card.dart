import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../features/trips/data/models/trip_model.dart';
import '../../features/trips/data/models/trip_status.dart';
import '../../l10n/l10n_extension.dart';
import 'status_chip.dart';
import 'route_progress.dart';
import 'driver_info_card.dart';
import 'capacity_bar.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final double pricePerKg;
  final String? driverName;
  final String? driverAvatarUrl;
  final String? vehicle;
  final double? rating;
  final int? deliveryCount;
  final double currentCapacity;
  final double maxCapacity;
  final VoidCallback? onTap;
  final bool isCompact;

  const TripCard({
    super.key,
    required this.trip,
    this.pricePerKg = 2.80,
    this.driverName,
    this.driverAvatarUrl,
    this.vehicle,
    this.rating,
    this.deliveryCount,
    this.currentCapacity = 0,
    this.maxCapacity = 100,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Status and date chips
            _HeaderSection(
              trip: trip,
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 14 : 18),

            // Price display
            _PriceSection(
              pricePerKg: trip.pricePerKg ?? pricePerKg,
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 16 : 22),

            // Route progress
            RouteProgress(
              origin: trip.originCity,
              destination: trip.destinationCity,
              originCountry: trip.originCountry,
              destinationCountry: trip.destinationCountry,
              progress: _getTripProgress(),
              compact: isCompact,
            ),
            SizedBox(height: isCompact ? 16 : 20),

            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    colors.divider,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: isCompact ? 14 : 18),

            // Driver info
            DriverInfoCard(
              name: driverName ?? context.l10n.tripCard_driver,
              avatarUrl: driverAvatarUrl,
              vehicle: vehicle ?? 'Mercedes Sprinter',
              rating: rating ?? 4.9,
              deliveryCount: deliveryCount ?? 0,
              compact: isCompact,
            ),
            SizedBox(height: isCompact ? 14 : 18),

            // Capacity bar
            CapacityBar(
              currentWeight: currentCapacity,
              maxCapacity: maxCapacity,
              compact: isCompact,
            ),
          ],
        ),
      ),
    );
  }

  double _getTripProgress() {
    switch (trip.status) {
      case TripStatus.planned:
        return 0.0;
      case TripStatus.inProgress:
        return 0.5;
      case TripStatus.completed:
        return 1.0;
      case TripStatus.cancelled:
        return 0.0;
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final TripModel trip;
  final bool isCompact;

  const _HeaderSection({required this.trip, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatusChip(
          label: trip.status.chipLabel,
          variant: trip.status.chipVariant,
          isCompact: isCompact,
        ),
        Row(
          children: [
            StatusChip.date(
              DateFormat('d MMM', localeCode).format(trip.departureDate),
            ),
            if (trip.departureTime != null) ...[
              const SizedBox(width: 8),
              StatusChip.time(
                '${trip.departureTime!.hour.toString().padLeft(2, '0')}:${trip.departureTime!.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PriceSection extends StatelessWidget {
  final double pricePerKg;
  final bool isCompact;

  const _PriceSection({required this.pricePerKg, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Price with gradient effect
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [colors.textPrimary, colors.textSecondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            pricePerKg.toStringAsFixed(2),
            style: TextStyle(
              fontSize: isCompact ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EUR',
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              '/kg',
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact version of TripCard for lists
class TripCardCompact extends StatelessWidget {
  final TripModel trip;
  final String? driverName;
  final VoidCallback? onTap;

  const TripCardCompact({
    super.key,
    required this.trip,
    this.driverName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trip.originCity} - ${trip.destinationCity}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(localeCode),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                      if (driverName != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: colors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            driverName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String localeCode) {
    final dateStr = DateFormat('d MMM', localeCode).format(trip.departureDate);
    if (trip.departureTime != null) {
      return '$dateStr, ${trip.departureTime!.hour.toString().padLeft(2, '0')}:${trip.departureTime!.minute.toString().padLeft(2, '0')}';
    }
    return dateStr;
  }

  Color _getStatusColor() {
    switch (trip.status) {
      case TripStatus.planned:
        return AppColors.info;
      case TripStatus.inProgress:
        return AppColors.primary;
      case TripStatus.completed:
        return AppColors.success;
      case TripStatus.cancelled:
        return AppColors.textMuted;
    }
  }
}

/// Featured trip card with image background
class FeaturedTripCard extends StatelessWidget {
  final TripModel trip;
  final String? imageUrl;
  final double pricePerKg;
  final VoidCallback? onTap;

  const FeaturedTripCard({
    super.key,
    required this.trip,
    this.imageUrl,
    this.pricePerKg = 2.80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.surfaceLight,
                    colors.cardBackground,
                  ],
                ),
              ),
            ),
            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  StatusChip(
                    label: trip.status.chipLabel,
                    variant: trip.status.chipVariant,
                  ),
                  const Spacer(),
                  // Route info
                  Text(
                    '${trip.originCity} - ${trip.destinationCity}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${(trip.pricePerKg ?? pricePerKg).toStringAsFixed(2)} EUR/kg',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM', localeCode)
                            .format(trip.departureDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
