import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';

class CapacityBar extends StatelessWidget {
  final double currentWeight;
  final double maxCapacity;
  final String? label;
  final bool showLabel;
  final bool showPercentage;
  final bool compact;

  const CapacityBar({
    super.key,
    required this.currentWeight,
    required this.maxCapacity,
    this.label,
    this.showLabel = true,
    this.showPercentage = false,
    this.compact = false,
  });

  double get percentage =>
      maxCapacity > 0 ? (currentWeight / maxCapacity).clamp(0.0, 1.0) : 0.0;

  Color get fillColor {
    if (percentage < 0.5) return AppColors.capacityFillLow;
    if (percentage < 0.85) return AppColors.capacityFill;
    return AppColors.capacityFillHigh;
  }

  Color get glowColor {
    if (percentage < 0.5) return AppColors.glowSuccess;
    if (percentage < 0.85) return AppColors.warning.withValues(alpha: 0.3);
    return AppColors.error.withValues(alpha: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final barHeight = compact ? 6.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label ?? 'Capacidad',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (showPercentage) ...[
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: fillColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    currentWeight.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: fillColor,
                    ),
                  ),
                  Text(
                    '/${maxCapacity.toStringAsFixed(0)} kg',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        // Progress bar with glow effect
        Container(
          height: barHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.capacityBackground,
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
          child: Stack(
            children: [
              // Animated fill
              AnimatedContainer(
                duration: AppTheme.durationNormal,
                curve: Curves.easeOutCubic,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fillColor.withValues(alpha: 0.8),
                          fillColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(barHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Shine effect
              if (percentage > 0.1)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 1,
                      left: 4,
                      right: 4,
                    ),
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Circular capacity indicator for compact spaces
class CircularCapacityIndicator extends StatelessWidget {
  final double currentWeight;
  final double maxCapacity;
  final double size;
  final double strokeWidth;

  const CircularCapacityIndicator({
    super.key,
    required this.currentWeight,
    required this.maxCapacity,
    this.size = 48,
    this.strokeWidth = 4,
  });

  double get percentage =>
      maxCapacity > 0 ? (currentWeight / maxCapacity).clamp(0.0, 1.0) : 0.0;

  Color get fillColor {
    if (percentage < 0.5) return AppColors.capacityFillLow;
    if (percentage < 0.85) return AppColors.capacityFill;
    return AppColors.capacityFillHigh;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(AppColors.capacityBackground),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage),
              duration: AppTheme.durationSlow,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(fillColor),
                );
              },
            ),
          ),
          // Percentage text
          Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
