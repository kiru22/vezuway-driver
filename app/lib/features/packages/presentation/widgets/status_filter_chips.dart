import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart';
import '../../data/models/package_model.dart';

class StatusFilterChips extends StatelessWidget {
  final PackageStatus? selectedStatus;
  final Function(PackageStatus?) onStatusSelected;
  final Map<String, int>? counts;

  const StatusFilterChips({
    super.key,
    this.selectedStatus,
    required this.onStatusSelected,
    this.counts,
  });

  String _buildLabel(String baseLabel, int? count) {
    if (count == null) return baseLabel;
    return '$baseLabel $count';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 8), // Vertical padding for shadows
      clipBehavior: Clip.none, // Allow shadows to overflow without clipping
      child: Row(
        children: [
          _FilterChip(
            label:
                _buildLabel(context.l10n.packages_filterAll, counts?['total']),
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          const SizedBox(width: 8),
          ...PackageStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: _buildLabel(
                      status.localizedName(context), counts?[status.apiValue]),
                  isSelected: selectedStatus == status,
                  onTap: () => onStatusSelected(status),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? null
                : (isDark ? colors.surface : Colors.white),
            gradient: widget.isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: widget.isSelected
                    ? Colors.white
                    : (isDark ? colors.textSecondary : const Color(0xFF334155)),
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.0,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}
