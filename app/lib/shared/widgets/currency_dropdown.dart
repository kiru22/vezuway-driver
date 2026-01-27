import 'package:flutter/material.dart';

import '../../core/theme/app_colors_extension.dart';
import '../../core/theme/theme_extensions.dart';

class CurrencyData {
  final String code;
  final String symbol;
  final String name;

  const CurrencyData({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const List<CurrencyData> all = [
    CurrencyData(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyData(code: 'UAH', symbol: '₴', name: 'Hryvnia'),
    CurrencyData(code: 'PLN', symbol: 'zł', name: 'Zloty'),
  ];

  static CurrencyData? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrencyCode;
  final ValueChanged<String> onCurrencySelected;
  final String? labelText;

  const CurrencyDropdown({
    super.key,
    this.selectedCurrencyCode = 'EUR',
    required this.onCurrencySelected,
    this.labelText,
  });

  Widget _buildCurrencyRow(CurrencyData currency, AppColorsExtension colors) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            currency.symbol,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            currency.code,
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
              value: selectedCurrencyCode,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colors.textMuted,
              ),
              items: CurrencyData.all.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency.code,
                  child: _buildCurrencyRow(currency, colors),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return CurrencyData.all
                    .map((currency) => _buildCurrencyRow(currency, colors))
                    .toList();
              },
              onChanged: (code) {
                if (code != null) {
                  onCurrencySelected(code);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
