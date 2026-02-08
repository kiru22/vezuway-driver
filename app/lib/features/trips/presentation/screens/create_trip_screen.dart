import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/utils/country_utils.dart';
import '../../../../shared/widgets/submit_bottom_bar.dart';
import '../../../../shared/widgets/themed_card.dart';
import '../../../routes/data/models/route_model.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../domain/providers/trip_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  final String? routeId;
  final String? tripId;

  const CreateTripScreen({super.key, this.routeId, this.tripId});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();

  Set<DateTime> _selectedDates = {};
  TimeOfDay? _departureTime;

  String _originCity = '';
  String _originCountry = 'UA';
  String _destinationCity = '';
  String _destinationCountry = 'ES';
  String _notes = '';

  RouteModel? _selectedRoute;
  bool _isLoading = false;
  bool _useTemplate = false;
  bool get _isEditing => widget.tripId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadTrip();
    } else if (widget.routeId != null) {
      _useTemplate = true;
      _loadRoute();
    }
  }

  Future<void> _loadTrip() async {
    setState(() => _isLoading = true);
    try {
      final trip =
          await ref.read(tripRepositoryProvider).getTrip(widget.tripId!);
      setState(() {
        _originCity = trip.originCity;
        _originCountry = trip.originCountry;
        _destinationCity = trip.destinationCity;
        _destinationCountry = trip.destinationCountry;
        _selectedDates = {
          DateTime(trip.departureDate.year, trip.departureDate.month, trip.departureDate.day),
        };
        _departureTime = trip.departureTime;
        _notes = trip.notes ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).common_error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadRoute() async {
    if (widget.routeId == null) return;

    setState(() => _isLoading = true);
    try {
      final route =
          await ref.read(routeRepositoryProvider).getRoute(widget.routeId!);
      setState(() {
        _selectedRoute = route;
        _originCity = route.origin;
        _originCountry = route.originCountry;
        _destinationCity = route.destination;
        _destinationCountry = route.destinationCountry;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).trips_errorLoadingTemplate),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final routesState = ref.watch(routesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? colors.background : AppColors.lightInputBg,
      appBar: AppBar(
        backgroundColor: isDark ? colors.background : AppColors.lightInputBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close, color: colors.textPrimary),
        ),
        title: Text(
          _isEditing ? l10n.trips_editTrip : l10n.tripsRoutes_createTrip,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (!_isEditing &&
                            routesState.routes.isNotEmpty &&
                            widget.routeId == null) ...[
                          _SectionTitle(title: l10n.trips_routeTemplate),
                          const SizedBox(height: 8),
                          _RouteSelector(
                            routes: routesState.routes,
                            selectedRoute: _selectedRoute,
                            onChanged: (route) {
                              setState(() {
                                _selectedRoute = route;
                                if (route != null) {
                                  _useTemplate = true;
                                  _originCity = route.origin;
                                  _originCountry = route.originCountry;
                                  _destinationCity = route.destination;
                                  _destinationCountry = route.destinationCountry;
                                } else {
                                  _useTemplate = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (!_isEditing && _selectedRoute != null) ...[
                          _RoutePreview(route: _selectedRoute!),
                          const SizedBox(height: 24),
                        ] else if (_isEditing || (!_useTemplate && widget.routeId == null)) ...[
                          _SectionTitle(title: l10n.trips_originPoint),
                          const SizedBox(height: 8),
                          _CityCountryInput(
                            cityHint: l10n.trips_cityHint,
                            initialCity: _originCity,
                            initialCountry: _originCountry,
                            onCityChanged: (v) => _originCity = v,
                            onCountryChanged: (v) =>
                                setState(() => _originCountry = v),
                          ),
                          const SizedBox(height: 16),
                          _SectionTitle(title: l10n.trips_destinationPoint),
                          const SizedBox(height: 8),
                          _CityCountryInput(
                            cityHint: l10n.trips_cityHint,
                            initialCity: _destinationCity,
                            initialCountry: _destinationCountry,
                            onCityChanged: (v) => _destinationCity = v,
                            onCountryChanged: (v) =>
                                setState(() => _destinationCountry = v),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (_isEditing) ...[
                          _SectionTitle(title: l10n.trips_departureDate),
                          const SizedBox(height: 8),
                          ThemedCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20, color: colors.textMuted),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDates.isNotEmpty
                                      ? DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(_selectedDates.first)
                                      : '',
                                  style: TextStyle(fontSize: 16, color: colors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          _SectionTitle(title: l10n.trips_departureDates),
                          const SizedBox(height: 8),
                          _MultiSelectCalendar(
                            selectedDates: _selectedDates,
                            onDatesChanged: (dates) {
                              setState(() => _selectedDates = dates);
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_selectedDates.isNotEmpty) ...[
                            _SelectedDatesChips(
                              dates: _selectedDates,
                              onRemove: (date) {
                                setState(() {
                                  _selectedDates.remove(date);
                                });
                              },
                              onClear: () {
                                setState(() {
                                  _selectedDates = {};
                                });
                              },
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),

                        _SectionTitle(title: l10n.trips_departureTimeOptional),
                        const SizedBox(height: 8),
                        _TimePickerField(
                          value: _departureTime,
                          onChanged: (time) =>
                              setState(() => _departureTime = time),
                        ),
                        const SizedBox(height: 24),

                        _SectionTitle(title: l10n.trips_notesOptional),
                        const SizedBox(height: 8),
                        ThemedCard(
                          child: TextFormField(
                            initialValue: _notes,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: l10n.trips_additionalInfo,
                              hintStyle: TextStyle(
                                color: isDark
                                    ? colors.textMuted
                                    : AppColors.lightTextSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (v) => _notes = v,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SubmitBottomBar(
                  onPressed:
                      _selectedDates.isEmpty || _isLoading ? null : _submit,
                  label: _getSubmitButtonLabel(),
                  isLoading: _isLoading,
                ),
              ],
            ),
    );
  }

  String _getSubmitButtonLabel() {
    final l10n = AppLocalizations.of(context);
    if (_isEditing) return l10n.common_save;
    if (_selectedDates.isEmpty) return l10n.trips_selectDates;
    if (_selectedDates.length == 1) return l10n.tripsRoutes_createTrip;
    return l10n.trips_createTripCount(_selectedDates.length);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);

    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.trips_selectAtLeastOneDate),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedRoute == null &&
        (_originCity.isEmpty || _destinationCity.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.trips_selectTemplateOrCities),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final date = _selectedDates.first;
        final data = <String, dynamic>{
          'origin_city': _originCity,
          'origin_country': _originCountry,
          'destination_city': _destinationCity,
          'destination_country': _destinationCountry,
          'departure_date': date.toIso8601String().split('T')[0],
          if (_departureTime != null)
            'departure_time':
                '${_departureTime!.hour.toString().padLeft(2, '0')}:${_departureTime!.minute.toString().padLeft(2, '0')}',
          if (_notes.isNotEmpty) 'notes': _notes,
        };

        final success = await ref
            .read(tripsProvider.notifier)
            .updateTrip(widget.tripId!, data);

        if (mounted) {
          if (success) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.trips_tripUpdated),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.trips_errorCreating),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
        return;
      }

      int successCount = 0;
      final sortedDates = _selectedDates.toList()..sort();

      for (final date in sortedDates) {
        bool success;
        if (_selectedRoute != null) {
          success = await ref.read(tripsProvider.notifier).createTripFromRoute(
                routeId: _selectedRoute!.id,
                departureDate: date,
                departureTime: _departureTime,
                notes: _notes.isEmpty ? null : _notes,
              );
        } else {
          success = await ref.read(tripsProvider.notifier).createTrip(
                originCity: _originCity,
                originCountry: _originCountry,
                destinationCity: _destinationCity,
                destinationCountry: _destinationCountry,
                departureDate: date,
                departureTime: _departureTime,
                notes: _notes.isEmpty ? null : _notes,
              );
        }
        if (success) successCount++;
      }

      if (mounted) {
        if (successCount == _selectedDates.length) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successCount == 1
                  ? l10n.trips_tripCreated
                  : l10n.trips_tripsCreated(successCount)),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (successCount > 0) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.trips_tripsPartiallyCreated(
                  successCount, _selectedDates.length)),
              backgroundColor: AppColors.warning,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.trips_errorCreating),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colors.textMuted,
        letterSpacing: 1,
      ),
    );
  }
}

class _MultiSelectCalendar extends StatefulWidget {
  final Set<DateTime> selectedDates;
  final Function(Set<DateTime>) onDatesChanged;

  const _MultiSelectCalendar({
    required this.selectedDates,
    required this.onDatesChanged,
  });

  @override
  State<_MultiSelectCalendar> createState() => _MultiSelectCalendarState();
}

class _MultiSelectCalendarState extends State<_MultiSelectCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    final monthFormat = DateFormat('MMMM yyyy', locale);

    return ThemedCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppTheme.radiusMd,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: Icon(Icons.chevron_left, color: colors.textPrimary),
              ),
              Text(
                _capitalizeFirst(monthFormat.format(_currentMonth)),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: Icon(Icons.chevron_right, color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              l10n.trips_weekdayMon,
              l10n.trips_weekdayTue,
              l10n.trips_weekdayWed,
              l10n.trips_weekdayThu,
              l10n.trips_weekdayFri,
              l10n.trips_weekdaySat,
              l10n.trips_weekdaySun,
            ]
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          _buildCalendarGrid(colors),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(AppColorsExtension colors) {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    final days = <Widget>[];

    for (var i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final isSelected = widget.selectedDates.contains(normalizedDate);
      final isToday = normalizedDate == today;
      final isPast = normalizedDate.isBefore(today);
      final canTap = !(isPast && !isSelected);

      days.add(_CalendarDayMultiSelect(
        day: day,
        isSelected: isSelected,
        isToday: isToday,
        isPast: isPast && !isSelected,
        onTap: canTap
            ? () {
                HapticFeedback.selectionClick();
                final newDates = Set<DateTime>.from(widget.selectedDates);
                if (isSelected) {
                  newDates.remove(normalizedDate);
                } else {
                  newDates.add(normalizedDate);
                }
                widget.onDatesChanged(newDates);
              }
            : null,
      ));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days,
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }
}

class _CalendarDayMultiSelect extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isPast;
  final VoidCallback? onTap;

  const _CalendarDayMultiSelect({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isPast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bgColor;
    Color textColor;

    if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = Colors.transparent;
      textColor = AppColors.primary;
    } else if (isPast) {
      bgColor = Colors.transparent;
      textColor = colors.textMuted.withValues(alpha: 0.5);
    } else {
      bgColor = Colors.transparent;
      textColor = colors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDatesChips extends StatelessWidget {
  final Set<DateTime> dates;
  final Function(DateTime) onRemove;
  final VoidCallback onClear;

  const _SelectedDatesChips({
    required this.dates,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final sortedDates = dates.toList()..sort();
    final dateFormat = DateFormat('dd.MM', Localizations.localeOf(context).languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...sortedDates.map((date) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dateFormat.format(date),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onRemove(date),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        if (dates.length > 1) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onClear,
            child: Text(
              l10n.trips_resetSelection,
              style: TextStyle(
                fontSize: 13,
                color: colors.textMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay? value;
  final Function(TimeOfDay?) onChanged;

  const _TimePickerField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        onChanged(picked);
      },
      child: ThemedCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20, color: colors.textMuted),
            const SizedBox(width: 12),
            Text(
              value != null
                  ? '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}'
                  : l10n.trips_notSpecified,
              style: TextStyle(
                fontSize: 16,
                color: value != null ? colors.textPrimary : colors.textMuted,
              ),
            ),
            if (value != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close, size: 18, color: colors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteSelector extends StatelessWidget {
  final List<RouteModel> routes;
  final RouteModel? selectedRoute;
  final Function(RouteModel?) onChanged;

  const _RouteSelector({
    required this.routes,
    required this.selectedRoute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final l10n = AppLocalizations.of(context);

    return ThemedCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RouteModel?>(
          value: selectedRoute,
          isExpanded: true,
          hint: Text(
            l10n.trips_selectTemplate,
            style: TextStyle(
              color: isDark ? colors.textMuted : AppColors.lightTextSecondary,
            ),
          ),
          icon: Icon(
            Icons.expand_more,
            color: isDark ? colors.textMuted : AppColors.lightTextSecondary,
          ),
          dropdownColor: isDark ? colors.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem<RouteModel?>(
              value: null,
              child: Text(
                l10n.trips_noTemplate,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ...routes.map((route) => DropdownMenuItem(
                  value: route,
                  child: Text(
                    route.displayName,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RoutePreview extends StatelessWidget {
  final RouteModel route;

  const _RoutePreview({required this.route});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ThemedCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteStopItem(
            icon: Icons.trip_origin,
            color: AppColors.success,
            label: '${route.origin}, ${route.originCountry}',
            isFirst: true,
          ),
          ...route.stops.map((stop) => _RouteStopItem(
                icon: Icons.circle,
                color: colors.border,
                label: '${stop.name}, ${stop.country}',
                isSmall: true,
              )),
          _RouteStopItem(
            icon: Icons.location_on,
            color: AppColors.error,
            label: '${route.destination}, ${route.destinationCountry}',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _RouteStopItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isFirst;
  final bool isLast;
  final bool isSmall;

  const _RouteStopItem({
    required this.icon,
    required this.color,
    required this.label,
    this.isFirst = false,
    this.isLast = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 8,
                  color: colors.border,
                ),
              Icon(icon, size: isSmall ? 8 : 16, color: color),
              if (!isLast)
                Container(
                  width: 2,
                  height: 8,
                  color: colors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            color: isSmall ? colors.textSecondary : colors.textPrimary,
            fontWeight: isSmall ? FontWeight.w400 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CityCountryInput extends StatelessWidget {
  final String cityHint;
  final String initialCity;
  final String initialCountry;
  final Function(String) onCityChanged;
  final Function(String) onCountryChanged;

  const _CityCountryInput({
    required this.cityHint,
    required this.initialCity,
    required this.initialCountry,
    required this.onCityChanged,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ThemedCard(
            child: TextFormField(
              initialValue: initialCity,
              decoration: InputDecoration(
                hintText: cityHint,
                hintStyle: TextStyle(
                  color: isDark
                      ? colors.textMuted
                      : AppColors.lightTextSecondary,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: onCityChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ThemedCard(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: initialCountry,
                isExpanded: true,
                icon: Icon(
                  Icons.expand_more,
                  color: isDark ? colors.textMuted : AppColors.lightTextSecondary,
                  size: 20,
                ),
                dropdownColor: isDark ? colors.surface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                items: ['UA', 'ES', 'PL', 'DE']
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            getCountryFlag(c),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => onCountryChanged(v ?? 'UA'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

