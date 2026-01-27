import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../utils/country_utils.dart';

/// A point in a route with city and country.
class RoutePoint {
  final String city;
  final String country;

  const RoutePoint({required this.city, required this.country});
}

/// Displays route points grouped by country with flag emojis.
///
/// Each country appears as a compact chip with:
/// - Flag emoji at the start
/// - Cities separated by bullet (•)
/// - "+X more" indicator if cities exceed [maxCitiesPerCountry]
class GroupedStopsDisplay extends StatelessWidget {
  final List<RoutePoint> points;
  final int maxCitiesPerCountry;

  const GroupedStopsDisplay({
    super.key,
    required this.points,
    this.maxCitiesPerCountry = 4,
  });

  /// Creates from a list of TripStopModel.
  factory GroupedStopsDisplay.fromTripStops({
    Key? key,
    required List<dynamic> stops,
    int maxCitiesPerCountry = 4,
  }) {
    final points = stops
        .map((s) => RoutePoint(
              city: s.city as String,
              country: s.country as String,
            ))
        .toList();
    return GroupedStopsDisplay(
      key: key,
      points: points,
      maxCitiesPerCountry: maxCitiesPerCountry,
    );
  }

  /// Creates from RouteModel data (origin, stops, destination).
  factory GroupedStopsDisplay.fromRoute({
    Key? key,
    required String origin,
    required String originCountry,
    required String destination,
    required String destinationCountry,
    required List<dynamic> stops,
    int maxCitiesPerCountry = 4,
  }) {
    final points = <RoutePoint>[
      RoutePoint(city: origin, country: originCountry),
      ...stops.map((s) => RoutePoint(
            city: s.name as String,
            country: s.country as String,
          )),
      RoutePoint(city: destination, country: destinationCountry),
    ];
    return GroupedStopsDisplay(
      key: key,
      points: points,
      maxCitiesPerCountry: maxCitiesPerCountry,
    );
  }

  /// Groups points by country while preserving order of first occurrence.
  Map<String, List<RoutePoint>> _groupByCountry() {
    final grouped = <String, List<RoutePoint>>{};
    final countryOrder = <String>[];

    for (final point in points) {
      final country = point.country.toUpperCase();
      if (!grouped.containsKey(country)) {
        grouped[country] = [];
        countryOrder.add(country);
      }
      grouped[country]!.add(point);
    }

    return {for (final country in countryOrder) country: grouped[country]!};
  }

  @override
  Widget build(BuildContext context) {
    final groupedPoints = _groupByCountry();
    if (groupedPoints.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedPoints.entries.map((entry) {
        return _CountryChip(
          country: entry.key,
          points: entry.value,
          maxCities: maxCitiesPerCountry,
        );
      }).toList(),
    );
  }
}

class _CountryChip extends StatelessWidget {
  final String country;
  final List<RoutePoint> points;
  final int maxCities;

  const _CountryChip({
    required this.country,
    required this.points,
    required this.maxCities,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final visiblePoints = points.take(maxCities).toList();
    final remainingCount = points.length - visiblePoints.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getCountryFlag(country),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children:
                    _buildCitySpans(context, visiblePoints, remainingCount),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildCitySpans(
    BuildContext context,
    List<RoutePoint> visiblePoints,
    int remainingCount,
  ) {
    final colors = context.colors;
    final spans = <InlineSpan>[];

    for (var i = 0; i < visiblePoints.length; i++) {
      if (i > 0) {
        spans.add(TextSpan(
          text: ' • ',
          style: TextStyle(
            fontSize: 12,
            color: colors.textMuted,
          ),
        ));
      }
      spans.add(TextSpan(
        text: visiblePoints[i].city,
        style: TextStyle(
          fontSize: 12,
          color: colors.textSecondary,
        ),
      ));
    }

    if (remainingCount > 0) {
      spans.add(TextSpan(
        text: ' • +$remainingCount',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.textMuted,
        ),
      ));
    }

    return spans;
  }
}
