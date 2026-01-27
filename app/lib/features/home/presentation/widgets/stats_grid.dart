import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/date_formatters.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../domain/providers/dashboard_provider.dart';

class StatsGrid extends ConsumerWidget {
  final DashboardStats stats;

  const StatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrip = stats.activeTrip ?? stats.nextTrip;
    final l10n = context.l10n;
    final formatters = ref.watch(dateFormattersProvider);

    if (currentTrip == null && stats.packagesCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentTrip != null) ...[
          // Active trip banner
          _ActiveTripBanner(
            origin: currentTrip.originCity,
            destination: currentTrip.destinationCity,
            date: currentTrip.departureDate,
            isActive: stats.activeTrip != null,
            dateFormatter: formatters.shortDate,
            activeTripLabel: l10n.home_activeTrip,
            nextTripLabel: l10n.home_nextTrip,
          ),
          const SizedBox(height: 20),
        ],
        // Stats cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.inventory_2_rounded,
                label: l10n.stats_packages,
                value: '${stats.packagesCount}',
                gradient: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.scale_rounded,
                label: l10n.stats_totalWeight,
                value:
                    '${stats.totalWeight.toStringAsFixed(1)} ${l10n.common_kg}',
                gradient: [AppColors.warning, const Color(0xFFD97706)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.euro_rounded,
                label: l10n.stats_declaredValue,
                value: stats.totalDeclaredValue.toStringAsFixed(0),
                gradient: [AppColors.success, const Color(0xFF16A34A)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActiveTripBanner extends StatelessWidget {
  final String origin;
  final String destination;
  final DateTime date;
  final bool isActive;
  final DateFormat dateFormatter;
  final String activeTripLabel;
  final String nextTripLabel;

  const _ActiveTripBanner({
    required this.origin,
    required this.destination,
    required this.date,
    required this.isActive,
    required this.dateFormatter,
    required this.activeTripLabel,
    required this.nextTripLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.cardBackground, colors.surfaceLight],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: isActive ? AppColors.primaryDark : colors.border,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isActive
                  ? AppColors.primaryGradient
                  : LinearGradient(
                      colors: [colors.surfaceElevated, colors.surfaceLight],
                    ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isActive ? Icons.local_shipping_rounded : Icons.schedule_rounded,
              color: isActive ? Colors.white : colors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Trip info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isActive) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isActive ? activeTripLabel : nextTripLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.success : colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$origin - $destination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: colors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormatter.format(date),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: colors.textMuted,
            size: 24,
          ),
        ],
      ),
    );
  }
}

/// Large stat card for featured metrics
class LargeStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool isTrendPositive;
  final List<Color> gradient;

  const LargeStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.isTrendPositive = true,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        (isTrendPositive ? AppColors.success : AppColors.error)
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: isTrendPositive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isTrendPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
