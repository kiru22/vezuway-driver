import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/date_formatters.dart';
import '../../../../l10n/status_localizations.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/package_box_icon.dart';
import '../../../packages/domain/providers/package_provider.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../../trips/data/models/trip_status.dart';

class UpcomingTripsList extends ConsumerWidget {
  final List<TripModel> trips;

  const UpcomingTripsList({
    super.key,
    required this.trips,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatters = ref.watch(dateFormattersProvider);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trips.isEmpty)
            EmptyState(
              icon: Icons.route_rounded,
              title: l10n.home_noScheduledRoutes,
              subtitle: l10n.home_createRoutePrompt,
            )
          else
            ...trips.take(3).map((trip) => _SimpleTripCard(
                  trip: trip,
                  dateFormatter: formatters.shortDateNoYear,
                  packagesLabel: l10n.packages_count(trip.packagesCount),
                  onTap: () => _onTripTap(context, ref, trip),
                )),
        ],
      ),
    );
  }

  void _onTripTap(BuildContext context, WidgetRef ref, TripModel trip) {
    HapticFeedback.lightImpact();
    ref.read(packagesProvider.notifier).filterByTrip(trip.id);
    context.go('/packages');
  }
}

class _SimpleTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;
  final DateFormat dateFormatter;
  final String packagesLabel;

  const _SimpleTripCard({
    required this.trip,
    required this.dateFormatter,
    required this.packagesLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: _getStatusGradient(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.route_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trip.originCity} - ${trip.destinationCity}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormatter.format(trip.departureDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      _StatusChip(status: trip.status),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      PackageBoxIcon(
                        size: 12,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        packagesLabel,
                        style: TextStyle(
                          fontSize: 13,
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

  LinearGradient _getStatusGradient() {
    switch (trip.status) {
      case TripStatus.planned:
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        );
      case TripStatus.inProgress:
        return AppColors.primaryGradient;
      case TripStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        );
      case TripStatus.cancelled:
        return LinearGradient(
          colors: [AppColors.surfaceElevated, AppColors.surfaceLight],
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final TripStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final chipColors = _getColors(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: chipColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          status.localizedName(context).toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: chipColors.text,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  ({Color background, Color text, Color border}) _getColors(
      BuildContext context) {
    final colors = context.colors;

    switch (status) {
      case TripStatus.planned:
        // Mismo estilo que StatusBadge de paquetes: verde claro transparente
        return (
          background: AppColors.success.withValues(alpha: 0.12),
          text: AppColors.success,
          border: AppColors.success.withValues(alpha: 0.3),
        );
      case TripStatus.inProgress:
        return (
          background: colors.chipOrange,
          text: colors.chipOrangeText,
          border: colors.chipOrangeBorder,
        );
      case TripStatus.completed:
        return (
          background: colors.chipGreen,
          text: colors.chipGreenText,
          border: colors.chipGreenBorder,
        );
      case TripStatus.cancelled:
        return (
          background: colors.chipGray,
          text: colors.chipGrayText,
          border: colors.chipGrayBorder,
        );
    }
  }
}
