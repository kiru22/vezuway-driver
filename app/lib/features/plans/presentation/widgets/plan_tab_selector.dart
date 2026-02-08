import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../screens/plans_screen.dart';
import 'gradient_border_painter.dart';

class PlanTabSelector extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String Function(String) planName;
  final List<PlanData> plans;

  const PlanTabSelector({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.planName,
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.cardBackground.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: List.generate(plans.length, (index) {
          final plan = plans[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
              onTap: () => onTap(index),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  plan.isPopular
                      ? _GradientBorderTab(
                          isSelected: isSelected,
                          accent: plan.accent,
                          accentDark: plan.accentDark,
                          child: _tabContent(plan, isSelected, colors),
                        )
                      : AnimatedContainer(
                          duration: AppTheme.durationNormal,
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? plan.accent.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: isSelected
                                ? Border.all(
                                    color:
                                        plan.accent.withValues(alpha: 0.3),
                                  )
                                : null,
                          ),
                          child: _tabContent(plan, isSelected, colors),
                        ),
                  if (plan.isPopular)
                    Positioned(
                      top: -8,
                      right: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          );
        }),
      ),
    );
  }

  Widget _tabContent(PlanData plan, bool isSelected, AppColorsExtension colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          planName(plan.nameKey),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? plan.accent : colors.textMuted,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _GradientBorderTab extends StatelessWidget {
  final bool isSelected;
  final Color accent;
  final Color accentDark;
  final Widget child;

  const _GradientBorderTab({
    required this.isSelected,
    required this.accent,
    required this.accentDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final borderOpacity = isSelected ? 0.8 : 0.4;
    final fillOpacity = isSelected ? 0.15 : 0.05;

    return CustomPaint(
      painter: GradientBorderPainter(
        gradient: LinearGradient(
          colors: [accent, accentDark],
        ),
        borderRadius: AppTheme.radiusFull,
        strokeWidth: 1.5,
        opacity: borderOpacity,
      ),
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: fillOpacity),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: child,
      ),
    );
  }
}
