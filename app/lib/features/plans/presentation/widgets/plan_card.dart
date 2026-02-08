import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../domain/providers/plan_request_provider.dart';
import '../screens/plans_screen.dart';
import 'gradient_border_painter.dart';
import 'price_radial_glow.dart';
import 'shimmer_sweep_overlay.dart';

class PlanCard extends StatelessWidget {
  final PlanData plan;
  final String planName;
  final bool isActive;

  const PlanCard({
    super.key,
    required this.plan,
    required this.planName,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final l10n = context.l10n;

    final glassBg =
        isDark ? AppColors.plansGlassDark : Colors.white.withValues(alpha: 0.5);
    final glassBorder =
        isDark ? AppColors.plansGlassDarkBorder : plan.accent.withValues(alpha: 0.15);

    final features = [
      _Feature(
        label: l10n.plans_featureScanner,
        value: plan.scannerLimit.toString(),
      ),
      _Feature(
        label: l10n.plans_featureSms,
        value: plan.smsLimit.toString(),
      ),
      _Feature(label: l10n.plans_shipmentHistory),
      _Feature(label: l10n.plans_contactBook),
      _Feature(label: l10n.plans_contactList),
    ];

    final hasGradientBorder =
        plan.nameKey == 'pro' || plan.nameKey == 'premium';
    final borderOpacity = isDark
        ? (isActive ? 0.8 : 0.4)
        : (isActive ? 1.0 : 0.6);

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTheme.plansGlassBlurSigma,
          sigmaY: AppTheme.plansGlassBlurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: hasGradientBorder
                ? null
                : Border.all(color: glassBorder, width: 1.5),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ShimmerSweepOverlay(
                  isActive: isActive,
                  borderRadius: AppTheme.radiusXl,
                  accent: plan.accent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Popular badge (top-right positioned via Stack)
                    if (plan.isPopular)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            l10n.plans_popular,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    if (!plan.isPopular) const SizedBox(height: 28),

                    const SizedBox(height: 8),

                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: plan.accent.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(
                          color: plan.accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        plan.icon,
                        color: plan.accent,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      planName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        PriceRadialGlow(
                          accent: plan.accent,
                        ),
                        Text(
                          '${plan.price}\u20AC',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            color: plan.accent,
                            letterSpacing: -3,
                            height: 1,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      l10n.plans_perMonth,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.6,
                          colors: [
                            plan.accent
                                .withValues(alpha: isDark ? 0.35 : 0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Column(
                        children: features.map((feature) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _FeatureRow(
                              feature: feature,
                              accent: plan.accent,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    _CtaButton(plan: plan, planName: planName),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with gradient border for Pro and Premium
    if (hasGradientBorder) {
      card = CustomPaint(
        foregroundPainter: GradientBorderPainter(
          gradient: LinearGradient(
            colors: [plan.accent, plan.accentDark],
          ),
          borderRadius: AppTheme.radiusXl,
          strokeWidth: 1.5,
          opacity: borderOpacity,
        ),
        child: card,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: isDark
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: plan.accent.withValues(alpha: 0.12),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: card,
    );
  }
}

class _Feature {
  final String label;
  final String? value;

  const _Feature({required this.label, this.value});
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  final Color accent;

  const _FeatureRow({
    required this.feature,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 14,
            color: accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            feature.value != null
                ? '${feature.label} — ${feature.value}'
                : feature.label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CtaButton extends ConsumerWidget {
  final PlanData plan;
  final String planName;

  const _CtaButton({
    required this.plan,
    required this.planName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final requestState = ref.watch(planRequestProvider);
    final isLoading = requestState.status == PlanRequestStatus.loading;
    final user = ref.watch(authProvider).user;
    final myRequest = ref.watch(myPlanRequestProvider).valueOrNull;

    // State 1: This plan is the user's active plan
    final isActivePlan = user?.activePlanKey == plan.nameKey;
    // State 2: There's a pending request for this plan
    final isPendingRequest =
        myRequest != null && myRequest.planKey == plan.nameKey;
    final isDisabled = isActivePlan || isPendingRequest;

    String buttonText;
    if (isActivePlan) {
      buttonText = l10n.plans_currentPlan;
    } else if (isPendingRequest) {
      buttonText = l10n.plans_requested;
    } else {
      buttonText = l10n.plans_selectPlan(planName);
    }

    return GestureDetector(
      onTap: isLoading || isDisabled
          ? null
          : () async {
              HapticFeedback.mediumImpact();
              final success =
                  await ref.read(planRequestProvider.notifier).submitRequest(
                        planKey: plan.nameKey,
                        planName: planName,
                        planPrice: plan.price,
                      );

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? l10n.plans_requestSuccess
                        : l10n.plans_requestError,
                  ),
                  backgroundColor: success ? AppColors.primary : Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [plan.accent, plan.accentDark],
                ),
          color: isDisabled
              ? (isActivePlan
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.15))
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: isActivePlan
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
              : null,
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: plan.accent.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isActivePlan) ...[
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (isPendingRequest && !isActivePlan) ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    buttonText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _buttonTextColor(
                        isActivePlan: isActivePlan,
                        isPendingRequest: isPendingRequest,
                      ),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static Color _buttonTextColor({
    required bool isActivePlan,
    required bool isPendingRequest,
  }) {
    if (isActivePlan) return AppColors.primary;
    if (isPendingRequest) return Colors.grey;
    return Colors.white;
  }
}
