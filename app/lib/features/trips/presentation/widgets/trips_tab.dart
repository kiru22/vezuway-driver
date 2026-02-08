import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../l10n/status_localizations.dart';
import '../../../../shared/widgets/country_flag.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/grouped_stops_display.dart';
import '../../../../shared/widgets/options_bottom_sheet.dart';
import '../../../../shared/widgets/package_box_icon.dart';
import '../../data/models/trip_model.dart';
import '../../domain/providers/trip_provider.dart';
import 'trips_calendar.dart';

class TripsTab extends ConsumerWidget {
  final VoidCallback onCreateTrip;
  final Future<void> Function(String tripId) onDelete;
  final Function(String tripId) onEdit;

  const TripsTab({
    super.key,
    required this.onCreateTrip,
    required this.onDelete,
    required this.onEdit,
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

            if (tripsState.filteredActiveTrips.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.trips_sectionActive,
                count: tripsState.filteredActiveTrips.length,
              ),
              const SizedBox(height: 12),
              ...tripsState.filteredActiveTrips.map((trip) => TripCard(
                    trip: trip,
                    onDelete: () => onDelete(trip.id),
                    onEdit: () => onEdit(trip.id),
                  )),
              const SizedBox(height: 24),
            ],

            if (tripsState.filteredUpcomingTrips.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.trips_sectionUpcoming,
                count: tripsState.filteredUpcomingTrips.length,
              ),
              const SizedBox(height: 12),
              ...tripsState.filteredUpcomingTrips.map((trip) => TripCard(
                    trip: trip,
                    onDelete: () => onDelete(trip.id),
                    onEdit: () => onEdit(trip.id),
                  )),
              const SizedBox(height: 24),
            ],

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
                        onDelete: () => onDelete(trip.id),
                        onEdit: () => onEdit(trip.id),
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
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TripCard({
    super.key,
    required this.trip,
    required this.onDelete,
    required this.onEdit,
  });

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = trip.departureDate.isBefore(today);
    final hasPackages = trip.packagesCount > 0;
    final canDelete = !isPast && !hasPackages;

    String? deleteBlockedReason;
    if (isPast) {
      deleteBlockedReason = l10n.trips_cannotDeletePast;
    } else if (hasPackages) {
      deleteBlockedReason = l10n.trips_cannotDeleteWithPackages;
    }

    showOptionsBottomSheet(context, sections: [
      BottomSheetSection(options: [
        BottomSheetOption(
          icon: Icons.edit_outlined,
          label: l10n.common_edit,
          subtitle: l10n.trips_editTripSubtitle,
          onTap: onEdit,
        ),
        BottomSheetOption(
          icon: Icons.delete_outline,
          label: l10n.common_delete,
          subtitle: l10n.trips_deleteTripSubtitle,
          isDestructive: true,
          enabled: canDelete,
          disabledReason: deleteBlockedReason,
          onTap: onDelete,
        ),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('d MMM', Localizations.localeOf(context).languageCode);

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
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CountryFlag(country: trip.originCountry),
                    const SizedBox(width: 8),
                    Flexible(
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
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showOptionsMenu(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: trip.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trip.status.localizedName(context).toUpperCase(),
                  style: TextStyle(
                    color: trip.status.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          if (trip.stops.isNotEmpty) ...[
            const SizedBox(height: 8),
            GroupedStopsDisplay.fromTripStops(
              stops: trip.stops,
              maxCitiesPerCountry: 4,
            ),
          ],
          const SizedBox(height: 12),
          _InfoChip(
            iconWidget: PackageBoxIcon(
                size: 14, color: context.colors.textMuted),
            label: AppLocalizations.of(context).trips_packagesCount(trip.packagesCount),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final Widget iconWidget;
  final String label;

  const _InfoChip({
    required this.iconWidget,
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
          iconWidget,
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
