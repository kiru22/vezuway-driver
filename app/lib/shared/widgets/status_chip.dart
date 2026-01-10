import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum ChipVariant {
  orange,
  blue,
  green,
  gray,
  purple,
}

class StatusChip extends StatelessWidget {
  final String label;
  final ChipVariant variant;
  final IconData? icon;
  final bool showBorder;
  final bool isCompact;

  const StatusChip({
    super.key,
    required this.label,
    this.variant = ChipVariant.gray,
    this.icon,
    this.showBorder = true,
    this.isCompact = false,
  });

  /// Factory para mostrar fecha con icono de calendario
  factory StatusChip.date(String date) {
    return StatusChip(
      label: date,
      variant: ChipVariant.gray,
      icon: Icons.calendar_today_rounded,
      showBorder: false,
    );
  }

  /// Factory para mostrar hora con icono de reloj
  factory StatusChip.time(String time) {
    return StatusChip(
      label: time,
      variant: ChipVariant.gray,
      icon: Icons.access_time_rounded,
      showBorder: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final horizontalPadding = isCompact ? 10.0 : 14.0;
    final verticalPadding = isCompact ? 5.0 : 7.0;
    final fontSize = isCompact ? 10.0 : 11.0;
    final iconSize = isCompact ? 12.0 : 13.0;

    return AnimatedContainer(
      duration: AppTheme.durationFast,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: showBorder
            ? Border.all(color: colors.border, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: colors.text,
            ),
            SizedBox(width: isCompact ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: colors.text,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  ({Color background, Color text, Color border}) _getColors() {
    switch (variant) {
      case ChipVariant.orange:
        return (
          background: AppColors.chipOrange,
          text: AppColors.chipOrangeText,
          border: AppColors.chipOrangeBorder,
        );
      case ChipVariant.blue:
        return (
          background: AppColors.chipBlue,
          text: AppColors.chipBlueText,
          border: AppColors.chipBlueBorder,
        );
      case ChipVariant.green:
        return (
          background: AppColors.chipGreen,
          text: AppColors.chipGreenText,
          border: AppColors.chipGreenBorder,
        );
      case ChipVariant.gray:
        return (
          background: AppColors.chipGray,
          text: AppColors.chipGrayText,
          border: AppColors.chipGrayBorder,
        );
      case ChipVariant.purple:
        return (
          background: AppColors.chipPurple,
          text: AppColors.chipPurpleText,
          border: AppColors.chipPurpleBorder,
        );
    }
  }
}
