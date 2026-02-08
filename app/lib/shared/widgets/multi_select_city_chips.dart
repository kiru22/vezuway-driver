import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../data/cities_data.dart';
import '../domain/providers/city_provider.dart';
import '../models/city_model.dart';

class MultiSelectCityChips extends StatelessWidget {
  final List<CityModel> selectedCities;
  final ValueChanged<List<CityModel>> onCitiesChanged;
  final String labelText;
  final String hintText;
  final List<String>? filterCountries;
  final List<CityModel>? excludeCities;

  const MultiSelectCityChips({
    super.key,
    required this.selectedCities,
    required this.onCitiesChanged,
    required this.labelText,
    required this.hintText,
    this.filterCountries,
    this.excludeCities,
  });

  void _removeCity(CityModel city) {
    final newList = selectedCities.where((c) => c != city).toList();
    onCitiesChanged(newList);
  }

  void _showAddCityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCityBottomSheet(
        existingCities: selectedCities,
        excludeCities: excludeCities,
        filterCountries: filterCountries,
        onCitySelected: (city) {
          final newList = [...selectedCities, city];
          onCitiesChanged(newList);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = context.l10n.localeName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.route_outlined,
              size: 20,
              color: colors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              labelText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            if (selectedCities.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selectedCities.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showAddCityModal(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hintText,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (selectedCities.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedCities.map((city) {
                    return _CityChip(
                      city: city,
                      locale: locale,
                      onRemove: () => _removeCity(city),
                    );
                  }).toList(),
                ),
              ],
              if (selectedCities.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.routes_noIntermediateStops,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CityChip extends StatelessWidget {
  final CityModel city;
  final String locale;
  final VoidCallback onRemove;

  const _CityChip({
    required this.city,
    required this.locale,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // Use explicit colors based on theme mode
    final chipBg = isDark ? const Color(0xFF172033) : const Color(0xFFEFF6FF);
    final chipText = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final chipBorder =
        isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBFDBFE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            city.getLocalizedName(locale),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: chipText,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Icon(
              Icons.close,
              size: 16,
              color: chipText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCityBottomSheet extends ConsumerStatefulWidget {
  final List<CityModel> existingCities;
  final List<CityModel>? excludeCities;
  final List<String>? filterCountries;
  final ValueChanged<CityModel> onCitySelected;

  const _AddCityBottomSheet({
    required this.existingCities,
    this.excludeCities,
    this.filterCountries,
    required this.onCitySelected,
  });

  @override
  ConsumerState<_AddCityBottomSheet> createState() =>
      _AddCityBottomSheetState();
}

class _AddCityBottomSheetState extends ConsumerState<_AddCityBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<CityModel> _filteredCities = [];
  bool _isSearching = false;
  String _locale = 'es';

  @override
  void initState() {
    super.initState();
    _filterCities('');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = context.l10n.localeName;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    _debounce?.cancel();

    final allExcluded = [
      ...widget.existingCities,
      ...?widget.excludeCities,
    ];

    if (query.length < 2) {
      setState(() {
        _isSearching = false;
        _filteredCities = CitiesData.searchCities(
          query,
          countries: widget.filterCountries,
          excludeCities: allExcluded,
        );
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await ref.read(
          citySearchProvider(CitySearchParams(
            query: query,
            countries: widget.filterCountries,
          )).future,
        );

        if (mounted) {
          setState(() {
            _filteredCities = results
                .where((city) => !allExcluded.contains(city))
                .toList();
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _filteredCities = CitiesData.searchCities(
              query,
              countries: widget.filterCountries,
              excludeCities: allExcluded,
            );
            _isSearching = false;
          });
        }
      }
    });
  }

  Widget _buildCitiesList(String noResultsText, double bottomPadding) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredCities.isEmpty) {
      return Center(
        child: Text(
          noResultsText,
          style: TextStyle(color: context.colors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        return ListTile(
          title: Text(city.getLocalizedName(_locale)),
          subtitle: Text(
            city.region != null
                ? '${city.getLocalizedCountry(_locale)} · ${city.region}'
                : city.getLocalizedCountry(_locale),
          ),
          onTap: () => widget.onCitySelected(city),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.routes_addStop,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _filterCities,
              decoration: InputDecoration(
                hintText: l10n.routes_searchCity,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildCitiesList(l10n.common_noResults, bottomPadding),
          ),
        ],
      ),
    );
  }
}
