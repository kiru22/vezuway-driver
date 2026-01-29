import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/data/cities_data.dart';
import '../../../../shared/models/city_model.dart';
import '../../../../shared/widgets/country_dropdown.dart';
import '../../../../shared/widgets/themed_card.dart';

/// Represents a route section with a country and multiple cities
class RouteSection {
  String? countryCode;
  List<CityModel> cities;

  RouteSection({
    this.countryCode,
    List<CityModel>? cities,
  }) : cities = cities ?? [];

  bool get isValid => countryCode != null && cities.isNotEmpty;

  RouteSection copyWith({
    String? countryCode,
    List<CityModel>? cities,
  }) {
    return RouteSection(
      countryCode: countryCode ?? this.countryCode,
      cities: cities ?? List.from(this.cities),
    );
  }
}

enum RouteSectionType { origin, intermediate, destination }

/// Compact version of RouteCountrySection used in timeline view
class RouteCountrySectionCompact extends StatelessWidget {
  final RouteSection section;
  final RouteSectionType type;
  final int? stopNumber;
  final ValueChanged<RouteSection> onSectionChanged;
  final VoidCallback? onDelete;

  const RouteCountrySectionCompact({
    super.key,
    required this.section,
    required this.type,
    this.stopNumber,
    required this.onSectionChanged,
    this.onDelete,
  });

  String _getTitle(BuildContext context) {
    final l10n = context.l10n;
    switch (type) {
      case RouteSectionType.origin:
        return l10n.routes_originPoint;
      case RouteSectionType.intermediate:
        return l10n.routes_stopN(stopNumber ?? 1);
      case RouteSectionType.destination:
        return l10n.routes_finalDestination;
    }
  }

  void _onCountryChanged(String countryCode) {
    onSectionChanged(RouteSection(
      countryCode: countryCode,
      cities: [],
    ));
  }

  void _addCity(BuildContext context) {
    if (section.countryCode == null) return;

    final locale = context.l10n.localeName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CitySearchSheet(
        countryCode: section.countryCode!,
        excludeCities: section.cities,
        locale: locale,
        onCitySelected: (city) {
          final newCities = List<CityModel>.from(section.cities)..add(city);
          onSectionChanged(section.copyWith(cities: newCities));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _removeCity(CityModel city) {
    final newCities = List<CityModel>.from(section.cities)..remove(city);
    onSectionChanged(section.copyWith(cities: newCities));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final locale = l10n.localeName;

    return ThemedCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colors, l10n),
          const SizedBox(height: 12),
          CountryDropdown(
            selectedCountryCode: section.countryCode,
            onCountrySelected: _onCountryChanged,
          ),
          const SizedBox(height: 12),
          if (section.countryCode != null)
            _buildCitiesSection(context, colors, l10n, locale),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic colors, dynamic l10n) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _getTitle(context),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
        if (onDelete != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onDelete!();
            },
            child: Text(
              l10n.routes_deleteStop.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCitiesSection(
    BuildContext context,
    dynamic colors,
    dynamic l10n,
    String locale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.routes_selectCity.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...section.cities.map((city) => _buildCityChip(city, colors, locale)),
        _buildAddCityButton(context, l10n),
      ],
    );
  }

  Widget _buildCityChip(CityModel city, dynamic colors, String locale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                city.getLocalizedName(locale),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _removeCity(city);
              },
              child: Icon(
                Icons.close,
                size: 18,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCityButton(BuildContext context, dynamic l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _addCity(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              l10n.routes_addCity,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  final String countryCode;
  final List<CityModel> excludeCities;
  final String locale;
  final ValueChanged<CityModel> onCitySelected;

  const _CitySearchSheet({
    required this.countryCode,
    required this.excludeCities,
    required this.locale,
    required this.onCitySelected,
  });

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final _searchController = TextEditingController();
  List<CityModel> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filterCities('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      _filteredCities = CitiesData.searchCities(
        query,
        countries: [widget.countryCode],
        excludeCities: widget.excludeCities,
        locale: widget.locale,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(colors),
          _buildSearchField(colors, l10n),
          Expanded(child: _buildCityList(colors, l10n)),
        ],
      ),
    );
  }

  Widget _buildHandle(AppColorsExtension colors) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSearchField(AppColorsExtension colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: _filterCities,
        decoration: InputDecoration(
          hintText: l10n.routes_searchCity,
          prefixIcon: Icon(Icons.search, color: colors.textMuted),
          filled: true,
          fillColor: colors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCityList(AppColorsExtension colors, AppLocalizations l10n) {
    if (_filteredCities.isEmpty) {
      return Center(
        child: Text(
          l10n.common_noResults,
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        return ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onCitySelected(city);
          },
          leading: Text(city.countryFlag, style: const TextStyle(fontSize: 20)),
          title: Text(
            city.getLocalizedName(widget.locale),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          subtitle: city.region != null
              ? Text(
                  city.region!,
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                )
              : null,
          trailing: const Icon(
            Icons.add_circle_outline,
            color: AppColors.primary,
          ),
        );
      },
    );
  }
}
