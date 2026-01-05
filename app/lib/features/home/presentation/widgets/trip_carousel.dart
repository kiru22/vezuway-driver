import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../routes/data/models/route_model.dart';

class UpcomingRoutesList extends StatelessWidget {
  final List<RouteModel> routes;

  const UpcomingRoutesList({
    super.key,
    required this.routes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Routes list
          if (routes.isEmpty)
            _EmptyState()
          else
            ...routes.take(3).map((route) => _SimpleRouteCard(
              route: route,
              onTap: () => _onRouteTap(context, route),
            )),
        ],
      ),
    );
  }

  void _onRouteTap(BuildContext context, RouteModel route) {
    HapticFeedback.lightImpact();
  }
}

class _SimpleRouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback? onTap;

  const _SimpleRouteCard({
    required this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM', 'es');
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Route icon with gradient
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: _getStatusGradient(),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.route_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Route info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_extractCity(route.origin)} - ${_extractCity(route.destination)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(route.departureDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 12,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${route.packagesCount} paquetes',
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
            // Status chip
            _StatusChip(status: route.status),
          ],
        ),
      ),
    );
  }

  String _extractCity(String location) {
    final parts = location.split(',');
    return parts.first.trim();
  }

  Color _getStatusColor() {
    switch (route.status) {
      case RouteStatus.planned:
        return AppColors.info;
      case RouteStatus.inProgress:
        return AppColors.primary;
      case RouteStatus.completed:
        return AppColors.success;
      case RouteStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  LinearGradient _getStatusGradient() {
    switch (route.status) {
      case RouteStatus.planned:
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        );
      case RouteStatus.inProgress:
        return AppColors.primaryGradient;
      case RouteStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        );
      case RouteStatus.cancelled:
        return LinearGradient(
          colors: [AppColors.surfaceElevated, AppColors.surfaceLight],
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final RouteStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final chipColors = _getColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: chipColors.border),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: chipColors.text,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  ({Color background, Color text, Color border}) _getColors(BuildContext context) {
    final colors = context.colors;

    switch (status) {
      case RouteStatus.planned:
        return (
          background: colors.chipBlue,
          text: colors.chipBlueText,
          border: colors.chipBlueBorder,
        );
      case RouteStatus.inProgress:
        return (
          background: colors.chipOrange,
          text: colors.chipOrangeText,
          border: colors.chipOrangeBorder,
        );
      case RouteStatus.completed:
        return (
          background: colors.chipGreen,
          text: colors.chipGreenText,
          border: colors.chipGreenBorder,
        );
      case RouteStatus.cancelled:
        return (
          background: colors.chipGray,
          text: colors.chipGrayText,
          border: colors.chipGrayBorder,
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.route_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin rutas programadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea una nueva ruta para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
