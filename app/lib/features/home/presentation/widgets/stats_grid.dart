import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/providers/dashboard_provider.dart';

class StatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const StatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final currentTrip = stats.activeTrip ?? stats.nextTrip;

    if (currentTrip == null && stats.packagesCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentTrip != null) ...[
          // Active trip banner
          _ActiveTripBanner(
            origin: currentTrip.origin,
            destination: currentTrip.destination,
            date: currentTrip.departureDate,
            isActive: stats.activeTrip != null,
          ),
          const SizedBox(height: 20),
        ],
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.inventory_2_rounded,
                label: 'Paquetes',
                value: '${stats.packagesCount}',
                gradient: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.scale_rounded,
                label: 'Peso total',
                value: '${stats.totalWeight.toStringAsFixed(1)} kg',
                gradient: [AppColors.warning, const Color(0xFFD97706)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.euro_rounded,
                label: 'Valor',
                value: '${stats.totalDeclaredValue.toStringAsFixed(0)}',
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

  const _ActiveTripBanner({
    required this.origin,
    required this.destination,
    required this.date,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

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
                      isActive ? 'Viaje activo' : 'Proximo viaje',
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
                    color: colorScheme.onSurface,
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
                      DateFormat('d MMMM yyyy', 'es').format(date),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with gradient background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          // Value with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppTheme.durationSlow,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 8 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textMuted,
            ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isTrendPositive ? AppColors.success : AppColors.error)
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
                        color: isTrendPositive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isTrendPositive ? AppColors.success : AppColors.error,
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
