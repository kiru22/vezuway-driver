import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/utils/country_utils.dart';
import '../../../routes/data/models/route_model.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../domain/providers/trip_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  final String? routeId;

  const CreateTripScreen({super.key, this.routeId});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selected dates (multiselect)
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

  @override
  void initState() {
    super.initState();
    if (widget.routeId != null) {
      _useTemplate = true;
      _loadRoute();
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
          const SnackBar(
            content: Text('Error al cargar la plantilla'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final routesState = ref.watch(routesProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close, color: colors.textPrimary),
        ),
        title: Text(
          'Створити рейс',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: _SubmitButton(
          onPressed: _submit,
          isLoading: _isLoading,
          tripCount: _selectedDates.length,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 1. Route selector FIRST
                  if (routesState.routes.isNotEmpty &&
                      widget.routeId == null) ...[
                    _SectionTitle(title: 'ШАБЛОН МАРШРУТУ'),
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

                  // Route details preview (if template selected)
                  if (_selectedRoute != null) ...[
                    _RoutePreview(route: _selectedRoute!),
                    const SizedBox(height: 24),
                  ] else if (!_useTemplate && widget.routeId == null) ...[
                    // Manual entry for origin/destination
                    _SectionTitle(title: 'ПУНКТ ВІДПРАВЛЕННЯ'),
                    const SizedBox(height: 8),
                    _CityCountryInput(
                      cityHint: 'Місто',
                      initialCity: _originCity,
                      initialCountry: _originCountry,
                      onCityChanged: (v) => _originCity = v,
                      onCountryChanged: (v) =>
                          setState(() => _originCountry = v),
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(title: 'ПУНКТ ПРИЗНАЧЕННЯ'),
                    const SizedBox(height: 8),
                    _CityCountryInput(
                      cityHint: 'Місто',
                      initialCity: _destinationCity,
                      initialCountry: _destinationCountry,
                      onCityChanged: (v) => _destinationCity = v,
                      onCountryChanged: (v) =>
                          setState(() => _destinationCountry = v),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 2. Calendar with multiselect
                  _SectionTitle(title: 'ДАТИ ВИЇЗДУ'),
                  const SizedBox(height: 8),
                  _MultiSelectCalendar(
                    selectedDates: _selectedDates,
                    onDatesChanged: (dates) {
                      setState(() => _selectedDates = dates);
                    },
                  ),
                  const SizedBox(height: 8),
                  // Selected dates chips
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
                          _selectedDates.clear();
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 3. Time picker (optional)
                  _SectionTitle(title: 'ЧАС ВИЇЗДУ (необов\'язково)'),
                  const SizedBox(height: 8),
                  _TimePickerField(
                    value: _departureTime,
                    onChanged: (time) => setState(() => _departureTime = time),
                  ),
                  const SizedBox(height: 24),

                  // 4. Notes
                  _SectionTitle(title: 'НОТАТКИ (необов\'язково)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _notes,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Додаткова інформація...',
                      filled: true,
                      fillColor: colors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                    onChanged: (v) => _notes = v,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Future<void> _submit() async {
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Виберіть хоча б одну дату'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedRoute == null &&
        (_originCity.isEmpty || _destinationCity.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Виберіть шаблон або вкажіть міста'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
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
                  ? 'Рейс створено!'
                  : 'Створено $successCount рейсів!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (successCount > 0) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Створено $successCount з ${_selectedDates.length} рейсів'),
              backgroundColor: AppColors.warning,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Помилка при створенні рейсів'),
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

// ============================================================================
// SECTION TITLE
// ============================================================================

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

// ============================================================================
// MULTI-SELECT CALENDAR
// ============================================================================

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
    final monthFormat = DateFormat('MMMM yyyy', 'uk');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Month navigation
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
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'НД']
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
          // Calendar grid
          _buildCalendarGrid(colors),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(dynamic colors) {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    final days = <Widget>[];

    // Empty cells for days before the first of the month
    for (var i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }

    // Days of the month
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final isSelected = widget.selectedDates.contains(normalizedDate);
      final isToday = normalizedDate == today;
      final isPast = normalizedDate.isBefore(today);

      days.add(_CalendarDayMultiSelect(
        day: day,
        isSelected: isSelected,
        isToday: isToday,
        isPast: isPast,
        onTap: isPast
            ? null
            : () {
                HapticFeedback.selectionClick();
                final newDates = Set<DateTime>.from(widget.selectedDates);
                if (isSelected) {
                  newDates.remove(normalizedDate);
                } else {
                  newDates.add(normalizedDate);
                }
                widget.onDatesChanged(newDates);
              },
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

// ============================================================================
// SELECTED DATES CHIPS
// ============================================================================

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
    final sortedDates = dates.toList()..sort();
    final dateFormat = DateFormat('dd.MM', 'uk');

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
              'Скинути вибір',
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

// ============================================================================
// TIME PICKER
// ============================================================================

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

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20, color: colors.textMuted),
            const SizedBox(width: 12),
            Text(
              value != null
                  ? '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}'
                  : 'Не вказано',
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

// ============================================================================
// ROUTE SELECTOR
// ============================================================================

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RouteModel?>(
          value: selectedRoute,
          isExpanded: true,
          hint: Text(
            'Виберіть шаблон',
            style: TextStyle(color: colors.textMuted),
          ),
          icon: Icon(Icons.expand_more, color: colors.textMuted),
          dropdownColor: colors.cardBackground,
          items: [
            DropdownMenuItem<RouteModel?>(
              value: null,
              child: Text(
                'Без шаблону (ввести вручну)',
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

// ============================================================================
// ROUTE PREVIEW
// ============================================================================

class _RoutePreview extends StatelessWidget {
  final RouteModel route;

  const _RoutePreview({required this.route});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
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

// ============================================================================
// CITY/COUNTRY INPUT
// ============================================================================

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

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: initialCity,
            decoration: InputDecoration(
              hintText: cityHint,
              filled: true,
              fillColor: colors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
            onChanged: onCityChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: initialCountry,
                isExpanded: true,
                icon:
                    Icon(Icons.expand_more, color: colors.textMuted, size: 20),
                dropdownColor: colors.cardBackground,
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

// ============================================================================
// SUBMIT BUTTON
// ============================================================================

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final int tripCount;

  const _SubmitButton({
    required this.onPressed,
    required this.isLoading,
    required this.tripCount,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = tripCount > 0;

    return GestureDetector(
      onTap: isLoading || !isEnabled
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onPressed();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isEnabled ? AppColors.primaryGradient : null,
          color: isEnabled ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      color: isEnabled ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tripCount == 0
                          ? 'Виберіть дати'
                          : tripCount == 1
                              ? 'Створити рейс'
                              : 'Створити $tripCount рейсів',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
