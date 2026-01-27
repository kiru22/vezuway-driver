import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/country_flag.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../routes/data/models/route_model.dart';
import '../../../routes/domain/providers/route_provider.dart';

class RoutesTab extends ConsumerWidget {
  final VoidCallback onCreateRoute;
  final Function(String routeId) onEdit;
  final Future<void> Function(String routeId) onDelete;

  const RoutesTab({
    super.key,
    required this.onCreateRoute,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final routesState = ref.watch(routesProvider);

    if (routesState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (routesState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(routesState.error!,
                style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(routesProvider.notifier).loadRoutes(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(routesProvider.notifier).loadRoutes(),
      color: AppColors.primary,
      child: routesState.routes.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: routesState.routes.length,
              itemBuilder: (context, index) {
                final route = routesState.routes[index];
                return RouteTemplateCard(
                  route: route,
                  onEdit: () => onEdit(route.id),
                  onDelete: () => onDelete(route.id),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: EmptyState(
                icon: Icons.route_outlined,
                title: 'Немає шаблонів маршрутів',
                subtitle: 'Створіть шаблон для швидкого створення рейсів',
                buttonText: l10n.quickAction_newRoute,
                onButtonPressed: onCreateRoute,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RouteTemplateCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RouteTemplateCard({
    super.key,
    required this.route,
    required this.onEdit,
    required this.onDelete,
  });

  void _showOptionsMenu(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.edit_outlined, color: AppColors.primary),
                ),
                title: const Text('Редагувати'),
                subtitle: Text(
                  'Змінити шаблон маршруту',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                ),
                title: const Text('Видалити',
                    style: TextStyle(color: AppColors.error)),
                subtitle: Text(
                  'Видалити шаблон маршруту',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CountryFlag(country: route.originCountry),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        route.origin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      ' - ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textMuted,
                      ),
                    ),
                    CountryFlag(country: route.destinationCountry),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        route.destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showOptionsMenu(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Route visualization with timeline, grouped by country
          _RouteTimeline(route: route),
        ],
      ),
    );
  }
}

/// Timeline visualization with cities grouped by country.
class _RouteTimeline extends StatelessWidget {
  final RouteModel route;

  const _RouteTimeline({required this.route});

  static const double rowHeight = 24.0;
  static const double mainX = 10.0;
  static const double indentedX = 28.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final countryGroups = _groupByCountry();

    // Build flat list with metadata
    final rows = <_CityRowData>[];
    var globalIndex = 0;
    final totalCities =
        countryGroups.fold<int>(0, (sum, g) => sum + g.cities.length);

    for (final group in countryGroups) {
      for (var i = 0; i < group.cities.length; i++) {
        rows.add(_CityRowData(
          city: group.cities[i],
          isFirstOverall: globalIndex == 0,
          isLastOverall: globalIndex == totalCities - 1,
          isFirstInCountry: i == 0,
        ));
        globalIndex++;
      }
    }

    return CustomPaint(
      painter: _ContinuousLinePainter(
        rows: rows,
        color: AppColors.primary.withValues(alpha: 0.4),
        rowHeight: rowHeight,
        mainX: mainX,
        indentedX: indentedX,
      ),
      child: Column(
        children: rows.map((data) {
          // First city of each country is on main column (including origin)
          // Only destination and intermediate cities are indented
          final isOnMainColumn = data.isFirstInCountry && !data.isLastOverall;
          final isIndented = !isOnMainColumn;
          return SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                // Main column icon
                SizedBox(
                  width: 20,
                  child: isOnMainColumn
                      ? Center(child: _buildIcon(data, colors))
                      : null,
                ),
                // Indented icon or spacer
                if (isIndented) ...[
                  SizedBox(
                    width: 16,
                    child: Center(child: _buildIcon(data, colors)),
                  ),
                  const SizedBox(width: 8),
                ] else
                  const SizedBox(width: 8),
                // City text
                Expanded(
                  child: Text(
                    data.city,
                    style: TextStyle(
                      fontSize: 14,
                      color: (data.isFirstOverall ||
                              data.isLastOverall ||
                              data.isFirstInCountry)
                          ? colors.textPrimary
                          : colors.textSecondary,
                      fontWeight: (data.isFirstOverall ||
                              data.isLastOverall ||
                              data.isFirstInCountry)
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIcon(_CityRowData data, dynamic colors) {
    if (data.isFirstOverall) {
      return Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      );
    } else if (data.isLastOverall) {
      return const Icon(Icons.location_on, size: 18, color: AppColors.primary);
    } else if (data.isFirstInCountry) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
      );
    }
  }

  List<_CountryGroup> _groupByCountry() {
    final allPoints = [
      _CityPoint(city: route.origin, country: route.originCountry),
      ...route.stops.map((s) => _CityPoint(city: s.name, country: s.country)),
      _CityPoint(city: route.destination, country: route.destinationCountry),
    ];

    final groups = <_CountryGroup>[];
    String? currentCountry;
    List<String> currentCities = [];

    for (final point in allPoints) {
      if (point.country != currentCountry) {
        if (currentCountry != null && currentCities.isNotEmpty) {
          groups.add(
              _CountryGroup(country: currentCountry, cities: currentCities));
        }
        currentCountry = point.country;
        currentCities = [point.city];
      } else {
        currentCities.add(point.city);
      }
    }

    if (currentCountry != null && currentCities.isNotEmpty) {
      groups.add(_CountryGroup(country: currentCountry, cities: currentCities));
    }

    return groups;
  }
}

class _CityRowData {
  final String city;
  final bool isFirstOverall;
  final bool isLastOverall;
  final bool isFirstInCountry;

  _CityRowData({
    required this.city,
    required this.isFirstOverall,
    required this.isLastOverall,
    required this.isFirstInCountry,
  });
}

class _CountryGroup {
  final String country;
  final List<String> cities;

  _CountryGroup({required this.country, required this.cities});
}

class _CityPoint {
  final String city;
  final String country;

  _CityPoint({required this.city, required this.country});
}

/// Draws one continuous curved line through all cities
class _ContinuousLinePainter extends CustomPainter {
  final List<_CityRowData> rows;
  final Color color;
  final double rowHeight;
  final double mainX;
  final double indentedX;

  _ContinuousLinePainter({
    required this.rows,
    required this.color,
    required this.rowHeight,
    required this.mainX,
    required this.indentedX,
  });

  bool _isOnMain(_CityRowData row) {
    // First city of each country (including origin), except destination
    return row.isFirstInCountry && !row.isLastOverall;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    const r = 8.0; // Curve radius
    const iconRadius = 6.0; // Space around icons

    // First row (origin) is on main column
    final firstY = rowHeight / 2;
    path.moveTo(mainX, firstY + iconRadius);

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final prevRow = rows[i - 1];
      final y = (i * rowHeight) + (rowHeight / 2);
      final prevY = ((i - 1) * rowHeight) + (rowHeight / 2);

      final isOnMain = _isOnMain(row);
      final prevOnMain = _isOnMain(prevRow);
      final isLast = i == rows.length - 1;

      if (!prevOnMain && isOnMain) {
        // Indented to main: curve left
        final curveStartY = prevY + iconRadius;
        final midY = curveStartY + (y - iconRadius - curveStartY) / 2;
        path.lineTo(indentedX, midY - r);
        path.quadraticBezierTo(indentedX, midY, indentedX - r, midY);
        path.lineTo(mainX + r, midY);
        path.quadraticBezierTo(mainX, midY, mainX, midY + r);
        path.lineTo(mainX, y - iconRadius);
      } else if (prevOnMain && !isOnMain) {
        // Main to indented: curve right
        final curveStartY = prevY + iconRadius;
        final targetY = isLast ? y - iconRadius : y;
        final midY = curveStartY + (targetY - curveStartY) / 2;
        path.lineTo(mainX, midY - r);
        path.quadraticBezierTo(mainX, midY, mainX + r, midY);
        path.lineTo(indentedX - r, midY);
        path.quadraticBezierTo(indentedX, midY, indentedX, midY + r);
        path.lineTo(indentedX, targetY);
      } else if (!prevOnMain && !isOnMain) {
        // Both indented: vertical line
        final endY = y - iconRadius;
        path.lineTo(indentedX, endY);
      } else {
        // Both on main: vertical line
        path.lineTo(mainX, y - iconRadius);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ContinuousLinePainter oldDelegate) {
    return oldDelegate.rows != rows || oldDelegate.color != color;
  }
}
