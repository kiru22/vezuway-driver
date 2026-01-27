import 'package:flutter/material.dart';

import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/theme_extensions.dart';
import '../../l10n/l10n_extension.dart';

class CountryData {
  final String code;
  final String flag;
  final String nameEn;
  final String nameEs;
  final String nameUk;

  const CountryData({
    required this.code,
    required this.flag,
    required this.nameEn,
    required this.nameEs,
    required this.nameUk,
  });

  String getLocalizedName(String locale) {
    if (locale.startsWith('uk')) return nameUk;
    if (locale.startsWith('es')) return nameEs;
    return nameEn;
  }

  static const List<CountryData> all = [
    CountryData(
      code: 'ES',
      flag: '🇪🇸',
      nameEn: 'Spain',
      nameEs: 'España',
      nameUk: 'Іспанія',
    ),
    CountryData(
      code: 'UA',
      flag: '🇺🇦',
      nameEn: 'Ukraine',
      nameEs: 'Ucrania',
      nameUk: 'Україна',
    ),
    CountryData(
      code: 'PL',
      flag: '🇵🇱',
      nameEn: 'Poland',
      nameEs: 'Polonia',
      nameUk: 'Польща',
    ),
    CountryData(
      code: 'DE',
      flag: '🇩🇪',
      nameEn: 'Germany',
      nameEs: 'Alemania',
      nameUk: 'Німеччина',
    ),
  ];

  static CountryData? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}

class CountryDropdown extends StatelessWidget {
  final String? selectedCountryCode;
  final ValueChanged<String> onCountrySelected;
  final String? labelText;
  final List<String>? excludeCountries;

  const CountryDropdown({
    super.key,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.labelText,
    this.excludeCountries,
  });

  Widget _buildCountryRow(
    CountryData country,
    String locale,
    AppColorsExtension colors,
  ) {
    return Row(
      children: [
        Text(
          country.flag,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            country.getLocalizedName(locale),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).languageCode;

    final availableCountries = CountryData.all
        .where((c) => !(excludeCountries?.contains(c.code) ?? false))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCountryCode,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colors.textMuted,
              ),
              hint: Text(
                context.l10n.routes_selectCountry,
                style: TextStyle(color: colors.textMuted),
              ),
              items: availableCountries.map((country) {
                return DropdownMenuItem<String>(
                  value: country.code,
                  child: _buildCountryRow(country, locale, colors),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return availableCountries
                    .map((c) => _buildCountryRow(c, locale, colors))
                    .toList();
              },
              onChanged: (code) {
                if (code != null) {
                  onCountrySelected(code);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
