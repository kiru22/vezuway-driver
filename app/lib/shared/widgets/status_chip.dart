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

  factory StatusChip.inTransit({String? label}) {
    return StatusChip(
      label: label ?? 'EN TRANSITO',
      variant: ChipVariant.orange,
    );
  }

  factory StatusChip.delivered({String? label}) {
    return StatusChip(
      label: label ?? 'ENTREGADO',
      variant: ChipVariant.green,
    );
  }

  factory StatusChip.pending({String? label}) {
    return StatusChip(
      label: label ?? 'PENDIENTE',
      variant: ChipVariant.gray,
    );
  }

  factory StatusChip.planned({String? label}) {
    return StatusChip(
      label: label ?? 'PLANIFICADA',
      variant: ChipVariant.blue,
    );
  }

  factory StatusChip.date(String date) {
    return StatusChip(
      label: date,
      variant: ChipVariant.gray,
      icon: Icons.calendar_today_rounded,
      showBorder: false,
    );
  }

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

/// Premium animated status indicator with glow effect
class StatusIndicator extends StatefulWidget {
  final bool isActive;
  final Color? activeColor;
  final double size;

  const StatusIndicator({
    super.key,
    this.isActive = true,
    this.activeColor,
    this.size = 8,
  });

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor ?? AppColors.success;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5 * _animation.value),
                      blurRadius: 8 * _animation.value,
                      spreadRadius: 2 * _animation.value,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
