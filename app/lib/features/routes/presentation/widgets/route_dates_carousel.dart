import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

class RouteDatesCarousel extends StatefulWidget {
  final List<DateTime> dates;
  final int pageSize;

  const RouteDatesCarousel({
    super.key,
    required this.dates,
    this.pageSize = 5,
  });

  @override
  State<RouteDatesCarousel> createState() => _RouteDatesCarouselState();
}

class _RouteDatesCarouselState extends State<RouteDatesCarousel> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Start on the page containing the next upcoming date
    _initCurrentPage();
  }

  void _initCurrentPage() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sortedDates = List<DateTime>.from(widget.dates)..sort();

    // Find the first future date
    final nextDateIndex = sortedDates.indexWhere((d) => !d.isBefore(todayStart));
    if (nextDateIndex >= 0) {
      _currentPage = nextDateIndex ~/ widget.pageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sortedDates = List<DateTime>.from(widget.dates)..sort();
    final dateFormat = DateFormat('d MMM', 'es');
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final totalPages = (sortedDates.length / widget.pageSize).ceil();
    final hasMultiplePages = totalPages > 1;

    // Get current page dates
    final startIndex = _currentPage * widget.pageSize;
    final endIndex = (startIndex + widget.pageSize).clamp(0, sortedDates.length);
    final pageDates = sortedDates.sublist(startIndex, endIndex);

    // Find the next upcoming date
    final nextDate = sortedDates.where((d) => !d.isBefore(todayStart)).firstOrNull;

    return Row(
      children: [
        // Previous page button
        if (hasMultiplePages)
          _NavButton(
            icon: Icons.chevron_left,
            enabled: _currentPage > 0,
            onTap: () {
              if (_currentPage > 0) {
                setState(() => _currentPage--);
              }
            },
          ),
        // Dates
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: pageDates.map((date) {
                final isPast = date.isBefore(todayStart);
                final isNext = nextDate != null &&
                    date.year == nextDate.year &&
                    date.month == nextDate.month &&
                    date.day == nextDate.day;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _DateChip(
                    label: dateFormat.format(date),
                    isPast: isPast,
                    isNext: isNext,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Next page button
        if (hasMultiplePages)
          _NavButton(
            icon: Icons.chevron_right,
            enabled: _currentPage < totalPages - 1,
            onTap: () {
              if (_currentPage < totalPages - 1) {
                setState(() => _currentPage++);
              }
            },
          ),
        // Page indicator
        if (hasMultiplePages)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${_currentPage + 1}/$totalPages',
              style: TextStyle(
                fontSize: 10,
                color: colors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: enabled ? colors.background : colors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? colors.textSecondary : colors.textMuted.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool isPast;
  final bool isNext;

  const _DateChip({
    required this.label,
    this.isPast = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bgColor;
    Color textColor;
    TextDecoration? decoration;

    if (isPast) {
      // Past dates - gray and strikethrough
      bgColor = colors.chipGray;
      textColor = colors.textMuted;
      decoration = TextDecoration.lineThrough;
    } else if (isNext) {
      // Next upcoming date - highlighted
      bgColor = colors.chipBlue;
      textColor = AppColors.primary;
      decoration = null;
    } else {
      // Future dates - normal style
      bgColor = colors.background;
      textColor = colors.textSecondary;
      decoration = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isNext ? null : Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
          color: textColor,
          decoration: decoration,
        ),
      ),
    );
  }
}
