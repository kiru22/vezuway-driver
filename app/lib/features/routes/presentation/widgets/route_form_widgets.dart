import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/models/city_model.dart';
import 'route_country_section.dart';

/// Dashed line used in route timeline
class DashedLine extends StatelessWidget {
  final Color color;

  const DashedLine({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(2, double.infinity),
      painter: _DashedLinePainter(color: color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Price field for route forms
class RoutePriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String suffix;

  const RoutePriceField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor: colors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Timeline icon for route sections
class RouteTimelineIcon extends StatelessWidget {
  final RouteSectionType type;
  final int? stopNumber;

  const RouteTimelineIcon({
    super.key,
    required this.type,
    this.stopNumber,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    switch (type) {
      case RouteSectionType.origin:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.circle,
              size: 10,
              color: AppColors.primary,
            ),
          ),
        );
      case RouteSectionType.intermediate:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Center(
            child: Text(
              '${stopNumber ?? 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      case RouteSectionType.destination:
        return const SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Icon(
              Icons.location_on,
              size: 22,
              color: AppColors.primary,
            ),
          ),
        );
    }
  }
}

/// Timeline item wrapper for route sections
class RouteTimelineItem extends StatelessWidget {
  final int index;
  final int totalSections;
  final RouteSectionType type;
  final RouteSection section;
  final ValueChanged<RouteSection> onSectionChanged;
  final int? stopNumber;
  final VoidCallback? onDelete;

  const RouteTimelineItem({
    super.key,
    required this.index,
    required this.totalSections,
    required this.type,
    required this.section,
    required this.onSectionChanged,
    this.stopNumber,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFirst = index == 0;
    final isLast = index == totalSections - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  SizedBox(
                    height: 8,
                    child: DashedLine(color: colors.border),
                  ),
                RouteTimelineIcon(type: type, stopNumber: stopNumber),
                if (!isLast)
                  Expanded(
                    child: DashedLine(color: colors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: RouteCountrySectionCompact(
                section: section,
                type: type,
                stopNumber: stopNumber,
                onSectionChanged: onSectionChanged,
                onDelete: onDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Build stops list for backend submission
List<CityModel> buildStopsForBackend({
  required RouteSection origin,
  required List<RouteSection> intermediateStops,
  required RouteSection destination,
}) {
  final stops = <CityModel>[];

  if (origin.cities.length > 1) {
    stops.addAll(origin.cities.skip(1));
  }

  for (final stop in intermediateStops) {
    if (stop.cities.isNotEmpty) {
      stops.addAll(stop.cities);
    }
  }

  if (destination.cities.length > 1) {
    stops.addAll(destination.cities.take(destination.cities.length - 1));
  }

  return stops;
}

/// Get currency symbol from code
String getCurrencySymbol(String currency) {
  switch (currency) {
    case 'EUR':
      return '\u20AC';
    case 'UAH':
      return '\u20B4';
    case 'PLN':
      return 'zl';
    default:
      return '\u20AC';
  }
}
