import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

class SelectedDatesChips extends StatelessWidget {
  final List<DateTime> dates;
  final ValueChanged<DateTime> onRemove;

  const SelectedDatesChips({
    super.key,
    required this.dates,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (dates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: colors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Toca los dias en el calendario para seleccionar',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final sortedDates = List<DateTime>.from(dates)..sort();
    final dateFormat = DateFormat('d MMM', 'es');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${dates.length} ${dates.length == 1 ? 'fecha seleccionada' : 'fechas seleccionadas'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedDates.map((date) {
              return _DateChip(
                date: date,
                label: dateFormat.format(date),
                onRemove: () => onRemove(date),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final String label;
  final VoidCallback onRemove;

  const _DateChip({
    required this.date,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.chipBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
