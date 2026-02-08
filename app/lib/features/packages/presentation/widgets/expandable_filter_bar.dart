import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../../trips/domain/providers/trip_provider.dart';
import '../../data/models/package_model.dart';
import '../../domain/providers/package_provider.dart';
import 'status_filter_chips.dart';

enum FilterType { search, status, trip, city }

class ExpandableFilterBar extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final PackageStatus? selectedStatus;
  final Function(PackageStatus?) onStatusSelected;
  final Map<String, int>? counts;
  final VoidCallback? onFilterChanged;

  const ExpandableFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.selectedStatus,
    required this.onStatusSelected,
    this.counts,
    this.onFilterChanged,
  });

  @override
  ConsumerState<ExpandableFilterBar> createState() =>
      _ExpandableFilterBarState();
}

class _ExpandableFilterBarState extends ConsumerState<ExpandableFilterBar> {
  FilterType _expandedFilter = FilterType.search;
  final _citySearchController = TextEditingController();
  String _citySearchQuery = '';
  final _searchFocusNode = FocusNode();
  final _citySearchFocusNode = FocusNode();

  @override
  void dispose() {
    _citySearchController.dispose();
    _searchFocusNode.dispose();
    _citySearchFocusNode.dispose();
    super.dispose();
  }

  void _toggleFilter(FilterType type) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_expandedFilter == type) {
        _expandedFilter = FilterType.search;
      } else {
        _expandedFilter = type;
      }
      if (_expandedFilter != FilterType.city) {
        _citySearchController.clear();
        _citySearchQuery = '';
      }
      if (_expandedFilter == FilterType.search) {
        _searchFocusNode.requestFocus();
        _citySearchFocusNode.unfocus();
      } else if (_expandedFilter == FilterType.city) {
        _searchFocusNode.unfocus();
        _citySearchFocusNode.requestFocus();
      } else {
        _searchFocusNode.unfocus();
        _citySearchFocusNode.unfocus();
      }
    });
  }

  bool _hasActiveFilter(FilterType type) {
    final packagesState = ref.read(packagesProvider);
    switch (type) {
      case FilterType.search:
        return widget.searchQuery.isNotEmpty;
      case FilterType.status:
        return packagesState.filterStatus != null;
      case FilterType.trip:
        return packagesState.tripId != null;
      case FilterType.city:
        return packagesState.filterCities.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSearchExpanded = _expandedFilter == FilterType.search;
    final searchHasValue = widget.searchQuery.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSearchExpanded)
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? colors.surface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: colors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widget.searchController,
                            focusNode: _searchFocusNode,
                            onChanged: widget.onSearchChanged,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: context.l10n.packages_searchPlaceholder,
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: colors.textMuted,
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (searchHasValue)
                          GestureDetector(
                            onTap: () {
                              widget.searchController.clear();
                              widget.onSearchChanged('');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.clear, size: 16, color: colors.textMuted),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                _FilterIconButton(
                  icon: Icons.search,
                  label: '',
                  isExpanded: false,
                  hasActiveFilter: searchHasValue,
                  onTap: () => _toggleFilter(FilterType.search),
                  isDark: isDark,
                  colors: colors,
                ),
              const SizedBox(width: 8),
              _FilterIconButton(
                icon: Icons.tune,
                label: context.l10n.packages_filterStatus,
                isExpanded: _expandedFilter == FilterType.status,
                hasActiveFilter: _hasActiveFilter(FilterType.status),
                onTap: () => _toggleFilter(FilterType.status),
                isDark: isDark,
                colors: colors,
              ),
              const SizedBox(width: 8),
              _FilterIconButton(
                icon: Icons.local_shipping_outlined,
                label: context.l10n.packages_filterTrip,
                isExpanded: _expandedFilter == FilterType.trip,
                hasActiveFilter: _hasActiveFilter(FilterType.trip),
                onTap: () => _toggleFilter(FilterType.trip),
                isDark: isDark,
                colors: colors,
              ),
              const SizedBox(width: 8),
              if (_expandedFilter == FilterType.city)
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _citySearchController,
                            focusNode: _citySearchFocusNode,
                            onChanged: (value) =>
                                setState(() => _citySearchQuery = value),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  context.l10n.packages_filterSearchCity,
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: colors.textMuted,
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_citySearchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _citySearchController.clear();
                              setState(() => _citySearchQuery = '');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.clear,
                                  size: 16, color: colors.textMuted),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                _FilterIconButton(
                  icon: Icons.location_on_outlined,
                  label: context.l10n.packages_filterCity,
                  isExpanded: false,
                  hasActiveFilter: _hasActiveFilter(FilterType.city),
                  onTap: () => _toggleFilter(FilterType.city),
                  isDark: isDark,
                  colors: colors,
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.topCenter,
          child: _expandedFilter != FilterType.search
              ? _buildExpandedContent()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    switch (_expandedFilter) {
      case FilterType.search:
        return const SizedBox.shrink();
      case FilterType.status:
        return StatusFilterChips(
          selectedStatus: widget.selectedStatus,
          onStatusSelected: widget.onStatusSelected,
          counts: widget.counts,
        );
      case FilterType.trip:
        return _TripFilterContent(
          onFilterChanged: widget.onFilterChanged,
        );
      case FilterType.city:
        return _CityFilterContent(
          searchQuery: _citySearchQuery,
        );
    }
  }
}

class _FilterIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final bool hasActiveFilter;
  final VoidCallback onTap;
  final bool isDark;
  final AppColorsExtension colors;

  const _FilterIconButton({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.hasActiveFilter,
    required this.onTap,
    required this.isDark,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isExpanded || hasActiveFilter;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 12 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? colors.surface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : colors.textMuted,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TripFilterContent extends ConsumerWidget {
  final VoidCallback? onFilterChanged;

  const _TripFilterContent({this.onFilterChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsState = ref.watch(tripsProvider);
    final packagesState = ref.watch(packagesProvider);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    if (tripsState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final active = tripsState.activeTrips;
    final upcoming = tripsState.upcomingTrips;
    final past = tripsState.completedTrips;

    if (active.isEmpty && upcoming.isEmpty && past.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            l10n.tripsRoutes_noTrips,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MiniTripCard(
              label: l10n.packages_filterAllTrips,
              subtitle: null,
              statusColor: colors.textMuted,
              isSelected: packagesState.tripId == null,
              onTap: () {
                ref.read(packagesProvider.notifier).filterByTrip(null);
                onFilterChanged?.call();
              },
              isDark: isDark,
              colors: colors,
            ),
            if (active.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionLabel(label: l10n.packages_filterActiveTrips),
              const SizedBox(height: 4),
              ...active.map((trip) => _buildTripCard(
                    context, ref, trip, packagesState.tripId, isDark, colors)),
            ],
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionLabel(label: l10n.packages_filterUpcomingTrips),
              const SizedBox(height: 4),
              ...upcoming.map((trip) => _buildTripCard(
                    context, ref, trip, packagesState.tripId, isDark, colors)),
            ],
            if (past.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionLabel(label: l10n.packages_filterPastTrips),
              const SizedBox(height: 4),
              ...past.take(5).map((trip) => _buildTripCard(
                    context, ref, trip, packagesState.tripId, isDark, colors)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, WidgetRef ref, TripModel trip,
      String? selectedTripId, bool isDark, AppColorsExtension colors) {
    final l10n = context.l10n;
    final dateFormat = DateFormat('d MMM', Localizations.localeOf(context).languageCode);
    final subtitle =
        '${dateFormat.format(trip.departureDate)} · ${l10n.packages_countShort(trip.packagesCount)}';

    return _MiniTripCard(
      label: '${trip.originCity} → ${trip.destinationCity}',
      subtitle: subtitle,
      statusColor: trip.status.color,
      isSelected: selectedTripId == trip.id,
      onTap: () {
        ref.read(packagesProvider.notifier).filterByTrip(trip.id);
        onFilterChanged?.call();
      },
      isDark: isDark,
      colors: colors,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: context.colors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _MiniTripCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color statusColor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final AppColorsExtension colors;

  const _MiniTripCard({
    required this.label,
    this.subtitle,
    required this.statusColor,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? colors.surface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : (isDark ? colors.surface : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 28,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _CityFilterContent extends ConsumerWidget {
  final String searchQuery;

  const _CityFilterContent({
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableCities = ref.watch(availableCitiesProvider);
    final packagesState = ref.watch(packagesProvider);
    final selectedCities = packagesState.filterCities;
    final l10n = context.l10n;

    final filteredCities = searchQuery.isEmpty
        ? availableCities
        : availableCities
            .where(
                (c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedCities.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: selectedCities.map((city) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _CityChip(
                              label: city,
                              isSelected: true,
                              onTap: () => ref
                                  .read(packagesProvider.notifier)
                                  .toggleCityFilter(city),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        ref.read(packagesProvider.notifier).clearCityFilter(),
                    child: Text(
                      l10n.packages_filterClearCities,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: filteredCities.map((city) {
                    final isSelected = selectedCities.contains(city);
                    return _CityChip(
                      label: city,
                      isSelected: isSelected,
                      onTap: () => ref
                          .read(packagesProvider.notifier)
                          .toggleCityFilter(city),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF64748B)),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
