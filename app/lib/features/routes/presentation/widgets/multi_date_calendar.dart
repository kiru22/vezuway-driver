import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

class MultiDateCalendar extends StatefulWidget {
  final List<DateTime> selectedDates;
  final ValueChanged<List<DateTime>> onDatesChanged;
  final DateTime? firstAllowedDate;

  const MultiDateCalendar({
    super.key,
    required this.selectedDates,
    required this.onDatesChanged,
    this.firstAllowedDate,
  });

  @override
  State<MultiDateCalendar> createState() => _MultiDateCalendarState();
}

class _MultiDateCalendarState extends State<MultiDateCalendar> {
  late DateTime _focusedDay;
  late Set<DateTime> _selectedDays;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDates.isNotEmpty
        ? widget.selectedDates.first
        : DateTime.now();
    _selectedDays = widget.selectedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  @override
  void didUpdateWidget(MultiDateCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDates != oldWidget.selectedDates) {
      _selectedDays = widget.selectedDates
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      final normalized = _normalizeDate(selectedDay);

      if (_selectedDays.contains(normalized)) {
        _selectedDays.remove(normalized);
      } else {
        _selectedDays.add(normalized);
      }
    });

    final sortedDates = _selectedDays.toList()..sort();
    widget.onDatesChanged(sortedDates);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final today = _normalizeDate(DateTime.now());
    final firstDay = widget.firstAllowedDate != null
        ? _normalizeDate(widget.firstAllowedDate!)
        : today;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TableCalendar(
          firstDay: firstDay,
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          locale: 'es_ES',
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) {
            return _selectedDays.contains(_normalizeDate(day));
          },
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mes',
          },
          calendarStyle: CalendarStyle(
            // Selected day styling
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            // Today styling
            todayDecoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            // Default day styling
            defaultTextStyle: TextStyle(
              color: colors.textPrimary,
            ),
            weekendTextStyle: TextStyle(
              color: colors.textSecondary,
            ),
            outsideDaysVisible: false,
            // Disabled days (past dates)
            disabledTextStyle: TextStyle(
              color: colors.textMuted,
            ),
            // Cell margin
            cellMargin: const EdgeInsets.all(4),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: AppColors.primary,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          enabledDayPredicate: (day) {
            // Disable past dates
            return !day.isBefore(firstDay);
          },
        ),
      ),
    );
  }
}
