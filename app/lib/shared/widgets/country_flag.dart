import 'package:flutter/material.dart';

import '../utils/country_utils.dart';

/// Displays a country flag emoji for a given country code.
///
/// Supports: UA (Ukraine), ES (Spain), PL (Poland), DE (Germany).
class CountryFlag extends StatelessWidget {
  final String country;
  final double fontSize;

  const CountryFlag({
    super.key,
    required this.country,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      getCountryFlag(country),
      style: TextStyle(fontSize: fontSize),
    );
  }
}
