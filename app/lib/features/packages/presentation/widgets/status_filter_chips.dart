import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart';
import '../../data/models/package_model.dart';

class StatusFilterChips extends StatelessWidget {
  final PackageStatus? selectedStatus;
  final Function(PackageStatus?) onStatusSelected;

  const StatusFilterChips({
    super.key,
    this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Vertical padding for shadows
      clipBehavior: Clip.none, // Allow shadows to overflow without clipping
      child: Row(
        children: [
          _FilterChip(
            label: context.l10n.packages_filterAll,
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          const SizedBox(width: 8),
          ...PackageStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: status.localizedName(context),
                  isSelected: selectedStatus == status,
                  onTap: () => onStatusSelected(status),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? null : (isDark ? colors.surface : Colors.white),
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(30), // More rounded pill shape
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null, // Clean look for unselected, or maybe subtle shadow if needed
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? colors.textSecondary : const Color(0xFF334155)), // Slate 700
              fontWeight: FontWeight.w700, // Bold for all
              fontSize: 13,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
