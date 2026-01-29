import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/utils/date_utils.dart' as date_utils;
import '../../data/models/trip_model.dart';

class TripsCalendar extends StatefulWidget {
  final Set<DateTime> departureDates;
  final Set<DateTime> datesWithPackages; // Dates that have trips with packages
  final List<TripModel> trips;
  final DateTime? selectedDate; // Controlado desde fuera (filtro activo)
  final DateTime? highlightedDate; // Proxima salida (resaltado por defecto)
  final Function(DateTime)? onDateSelected;
  final VoidCallback? onClearFilter;
  final bool showClearFilter;

  const TripsCalendar({
    super.key,
    required this.departureDates,
    this.datesWithPackages = const {},
    required this.trips,
    this.selectedDate,
    this.highlightedDate,
    this.onDateSelected,
    this.onClearFilter,
    this.showClearFilter = false,
  });

  @override
  State<TripsCalendar> createState() => _TripsCalendarState();
}

class _TripsCalendarState extends State<TripsCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    // Start at the month of the selected/highlighted date, or current month
    final targetDate =
        widget.selectedDate ?? widget.highlightedDate ?? DateTime.now();
    _currentMonth = DateTime(targetDate.year, targetDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final monthFormat = DateFormat('MMMM yyyy', 'uk');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: Icon(Icons.chevron_left, color: colors.textPrimary),
              ),
              Text(
                _capitalizeFirst(monthFormat.format(_currentMonth)),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: Icon(Icons.chevron_right, color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд']
                .map((day) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          _buildCalendarGrid(),

          // Clear filter button
          if (widget.showClearFilter) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: widget.onClearFilter,
                icon: Icon(
                  Icons.clear,
                  size: 18,
                  color: colors.textMuted,
                ),
                label: Text(
                  l10n.trips_clearFilter,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    final days = <Widget>[];

    // Empty cells for days before the first of the month
    for (var i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox.shrink());
    }

    // Days of the month
    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final hasTrip = widget.departureDates.contains(date);
      final hasPackages = widget.datesWithPackages.contains(date);
      final isToday = date_utils.isToday(date);
      final isSelected =
          widget.selectedDate != null && date_utils.isSameDay(date, widget.selectedDate!);

      days.add(_CalendarDay(
        day: day,
        hasTrip: hasTrip,
        hasPackages: hasPackages,
        isToday: isToday,
        isSelected: isSelected,
        onTap: hasTrip ? () => widget.onDateSelected?.call(date) : null,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool hasTrip;
  final bool hasPackages;
  final bool isToday;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CalendarDay({
    required this.day,
    required this.hasTrip,
    this.hasPackages = false,
    required this.isToday,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isTodayNotSelected = isToday && !isSelected;
    final showDot = hasPackages && !isToday;

    final Color textColor;
    final Color? bgColor;
    final Gradient? gradient;

    if (isTodayNotSelected) {
      gradient = AppColors.primaryGradient;
      bgColor = null;
      textColor = Colors.white;
    } else if (hasTrip) {
      gradient = null;
      bgColor = AppColors.success.withValues(alpha: 0.15);
      textColor = AppColors.success;
    } else {
      gradient = null;
      bgColor = Colors.transparent;
      textColor = colors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
          border: isSelected && hasTrip
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasTrip || isToday || isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (showDot)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
