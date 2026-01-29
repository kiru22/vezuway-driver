import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/country_flag.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/grouped_stops_display.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/trip_status.dart';
import '../../domain/providers/trip_provider.dart';
import 'trips_calendar.dart';

class TripsTab extends ConsumerWidget {
  final VoidCallback onCreateTrip;
  final void Function(String tripId, TripStatus status) onStatusChange;
  final Future<void> Function(String tripId) onDelete;

  const TripsTab({
    super.key,
    required this.onCreateTrip,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final tripsState = ref.watch(tripsProvider);

    if (tripsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (tripsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(tripsState.error!,
                style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(tripsProvider.notifier).loadTrips(),
              child: Text(l10n.trips_retry),
            ),
          ],
        ),
      );
    }

    if (tripsState.trips.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tripsProvider.notifier).loadTrips(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar with filter integration
            TripsCalendar(
              departureDates: tripsState.departureDates,
              datesWithPackages: tripsState.datesWithPackages,
              trips: tripsState.trips,
              selectedDate: tripsState.filterDate,
              highlightedDate: tripsState.nextDepartureDate,
              showClearFilter: tripsState.filterDate != null,
              onDateSelected: (date) =>
                  ref.read(tripsProvider.notifier).filterByDate(date),
              onClearFilter: () =>
                  ref.read(tripsProvider.notifier).clearDateFilter(),
            ),
            const SizedBox(height: 24),

            // Active trips (filtered)
            if (tripsState.filteredActiveTrips.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.trips_sectionActive,
                count: tripsState.filteredActiveTrips.length,
              ),
              const SizedBox(height: 12),
              ...tripsState.filteredActiveTrips.map((trip) => TripCard(
                    trip: trip,
                    onStatusChange: (status) => onStatusChange(trip.id, status),
                    onDelete: () => onDelete(trip.id),
                  )),
              const SizedBox(height: 24),
            ],

            // Upcoming trips (filtered)
            if (tripsState.filteredUpcomingTrips.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.trips_sectionUpcoming,
                count: tripsState.filteredUpcomingTrips.length,
              ),
              const SizedBox(height: 12),
              ...tripsState.filteredUpcomingTrips.map((trip) => TripCard(
                    trip: trip,
                    onStatusChange: (status) => onStatusChange(trip.id, status),
                    onDelete: () => onDelete(trip.id),
                  )),
              const SizedBox(height: 24),
            ],

            // Completed trips (filtered)
            if (tripsState.filteredCompletedTrips.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.trips_sectionHistory,
                count: tripsState.filteredCompletedTrips.length,
              ),
              const SizedBox(height: 12),
              ...tripsState.filteredCompletedTrips
                  .take(5)
                  .map((trip) => TripCard(
                        trip: trip,
                        onStatusChange: (status) =>
                            onStatusChange(trip.id, status),
                        onDelete: () => onDelete(trip.id),
                      )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return EmptyState(
      icon: Icons.directions_car_outlined,
      title: l10n.tripsRoutes_noTrips,
      subtitle: l10n.tripsRoutes_noTripsSubtitle,
      buttonText: l10n.tripsRoutes_createTrip,
      onButtonPressed: onCreateTrip,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class TripCard extends StatelessWidget {
  final TripModel trip;
  final void Function(TripStatus) onStatusChange;
  final VoidCallback onDelete;

  const TripCard({
    super.key,
    required this.trip,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('d MMM', 'uk');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CountryFlag(country: trip.originCountry),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CountryFlag(country: trip.destinationCountry),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: trip.status.displayNameUk.toUpperCase(),
                variant: _getStatusVariant(trip.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date and time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: colors.textMuted),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(trip.departureDate),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              if (trip.departureTime != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 16, color: colors.textMuted),
                const SizedBox(width: 4),
                Text(
                  trip.formattedDepartureTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          // Stops preview grouped by country
          if (trip.stops.isNotEmpty) ...[
            const SizedBox(height: 8),
            GroupedStopsDisplay.fromTripStops(
              stops: trip.stops,
              maxCitiesPerCountry: 4,
            ),
          ],
          const SizedBox(height: 12),
          // Info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: AppLocalizations.of(context).trips_packagesCount(trip.packagesCount),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.sync_alt_rounded,
                    onTap: () => _showStatusChangeSheet(context),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    isDestructive: true,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  ChipVariant _getStatusVariant(TripStatus status) {
    switch (status) {
      case TripStatus.planned:
        return ChipVariant.green;
      case TripStatus.inProgress:
        return ChipVariant.orange;
      case TripStatus.completed:
        return ChipVariant.green;
      case TripStatus.cancelled:
        return ChipVariant.gray;
    }
  }

  void _showStatusChangeSheet(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).trips_changeStatus,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...TripStatus.values
                .where((s) => s != trip.status)
                .map((status) => _StatusOption(
                      status: status,
                      onTap: () {
                        Navigator.pop(context);
                        onStatusChange(status);
                      },
                    )),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final TripStatus status;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              status.displayNameUk,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
