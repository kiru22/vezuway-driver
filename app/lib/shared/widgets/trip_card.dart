import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/routes/data/models/route_model.dart';
import 'status_chip.dart';
import 'route_progress.dart';
import 'driver_info_card.dart';
import 'capacity_bar.dart';

class TripCard extends StatelessWidget {
  final RouteModel route;
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
    required this.route,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.2),
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
              route: route,
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 14 : 18),

            // Price display
            _PriceSection(
              pricePerKg: pricePerKg,
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 16 : 22),

            // Route progress
            RouteProgress(
              origin: _extractCity(route.origin),
              destination: _extractCity(route.destination),
              originCountry: _extractCountry(route.origin),
              destinationCountry: _extractCountry(route.destination),
              progress: _getRouteProgress(),
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
                    AppColors.divider,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: isCompact ? 14 : 18),

            // Driver info
            DriverInfoCard(
              name: driverName ?? 'Conductor',
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

  String _getStatusLabel() {
    switch (route.status) {
      case RouteStatus.planned:
        return 'PLANIFICADA';
      case RouteStatus.inProgress:
        return 'EN TRANSITO';
      case RouteStatus.completed:
        return 'COMPLETADA';
      case RouteStatus.cancelled:
        return 'CANCELADA';
    }
  }

  ChipVariant _getStatusVariant() {
    switch (route.status) {
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

  String _extractCity(String location) {
    final parts = location.split(',');
    return parts.first.trim();
  }

  String _extractCountry(String location) {
    final parts = location.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    if (location.toLowerCase().contains('madrid') ||
        location.toLowerCase().contains('barcelona') ||
        location.toLowerCase().contains('valencia')) {
      return 'Espana';
    }
    if (location.toLowerCase().contains('kyiv') ||
        location.toLowerCase().contains('kiev') ||
        location.toLowerCase().contains('lviv') ||
        location.toLowerCase().contains('odesa')) {
      return 'Ucrania';
    }
    return '';
  }

  double _getRouteProgress() {
    switch (route.status) {
      case RouteStatus.planned:
        return 0.0;
      case RouteStatus.inProgress:
        return 0.5;
      case RouteStatus.completed:
        return 1.0;
      case RouteStatus.cancelled:
        return 0.0;
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final RouteModel route;
  final bool isCompact;

  const _HeaderSection({required this.route, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatusChip(
          label: _getStatusLabel(),
          variant: _getStatusVariant(),
          isCompact: isCompact,
        ),
        Row(
          children: [
            StatusChip.date(
              DateFormat('d MMM', 'es').format(route.departureDate),
            ),
            if (route.estimatedArrival != null) ...[
              const SizedBox(width: 8),
              StatusChip.time(
                DateFormat('HH:mm').format(route.departureDate),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getStatusLabel() {
    switch (route.status) {
      case RouteStatus.planned:
        return 'PLANIFICADA';
      case RouteStatus.inProgress:
        return 'EN TRANSITO';
      case RouteStatus.completed:
        return 'COMPLETADA';
      case RouteStatus.cancelled:
        return 'CANCELADA';
    }
  }

  ChipVariant _getStatusVariant() {
    switch (route.status) {
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

class _PriceSection extends StatelessWidget {
  final double pricePerKg;
  final bool isCompact;

  const _PriceSection({required this.pricePerKg, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Price with gradient effect
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.textPrimary, AppColors.textSecondary],
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
                color: AppColors.textMuted,
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
  final RouteModel route;
  final String? driverName;
  final VoidCallback? onTap;

  const TripCardCompact({
    super.key,
    required this.route,
    this.driverName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.border),
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
                    '${_extractCity(route.origin)} - ${_extractCity(route.destination)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM, HH:mm', 'es').format(route.departureDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (driverName != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            driverName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
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
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _extractCity(String location) {
    final parts = location.split(',');
    return parts.first.trim();
  }

  Color _getStatusColor() {
    switch (route.status) {
      case RouteStatus.planned:
        return AppColors.info;
      case RouteStatus.inProgress:
        return AppColors.primary;
      case RouteStatus.completed:
        return AppColors.success;
      case RouteStatus.cancelled:
        return AppColors.textMuted;
    }
  }
}

/// Featured trip card with image background
class FeaturedTripCard extends StatelessWidget {
  final RouteModel route;
  final String? imageUrl;
  final double pricePerKg;
  final VoidCallback? onTap;

  const FeaturedTripCard({
    super.key,
    required this.route,
    this.imageUrl,
    this.pricePerKg = 2.80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppColors.border),
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
                    AppColors.surfaceLight,
                    AppColors.cardBackground,
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
                    AppColors.background.withValues(alpha: 0.9),
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
                    label: _getStatusLabel(),
                    variant: _getStatusVariant(),
                  ),
                  const Spacer(),
                  // Route info
                  Text(
                    '${_extractCity(route.origin)} - ${_extractCity(route.destination)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${pricePerKg.toStringAsFixed(2)} EUR/kg',
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
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM', 'es').format(route.departureDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
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

  String _extractCity(String location) {
    final parts = location.split(',');
    return parts.first.trim();
  }

  String _getStatusLabel() {
    switch (route.status) {
      case RouteStatus.planned:
        return 'PLANIFICADA';
      case RouteStatus.inProgress:
        return 'EN TRANSITO';
      case RouteStatus.completed:
        return 'COMPLETADA';
      case RouteStatus.cancelled:
        return 'CANCELADA';
    }
  }

  ChipVariant _getStatusVariant() {
    switch (route.status) {
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
