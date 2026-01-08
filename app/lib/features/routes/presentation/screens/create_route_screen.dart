import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/models/city_model.dart';
import '../../../../shared/widgets/multi_select_city_chips.dart';
import '../../../../shared/widgets/searchable_city_dropdown.dart';
import '../../domain/providers/route_provider.dart';
import '../widgets/multi_date_calendar.dart';
import '../widgets/selected_dates_chips.dart';

class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pricePerKgController = TextEditingController();
  final _minimumPriceController = TextEditingController();
  final _multiplierController = TextEditingController(text: '1.0');
  final _tripDurationController = TextEditingController();

  CityModel? _originCity;
  CityModel? _destinationCity;
  List<CityModel> _stops = [];
  List<DateTime> _selectedDepartureDates = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _pricePerKgController.dispose();
    _minimumPriceController.dispose();
    _multiplierController.dispose();
    _tripDurationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_originCity == null) {
      _showError(context.l10n.routes_originRequired);
      return;
    }

    if (_destinationCity == null) {
      _showError(context.l10n.routes_destinationRequired);
      return;
    }

    if (_selectedDepartureDates.isEmpty) {
      _showError(context.l10n.routes_atLeastOneDate);
      return;
    }

    setState(() => _isLoading = true);

    final tripDuration = int.tryParse(_tripDurationController.text);
    final pricePerKg = double.tryParse(_pricePerKgController.text.replaceAll(',', '.'));
    final minimumPrice = double.tryParse(_minimumPriceController.text.replaceAll(',', '.'));
    final multiplier = double.tryParse(_multiplierController.text.replaceAll(',', '.'));

    final success = await ref.read(routesProvider.notifier).createRoute(
          origin: _originCity!.name,
          originCountry: _originCity!.country,
          destination: _destinationCity!.name,
          destinationCountry: _destinationCity!.country,
          departureDates: _selectedDepartureDates,
          tripDurationHours: tripDuration,
          stops: _stops.isNotEmpty ? _stops : null,
          pricePerKg: pricePerKg,
          minimumPrice: minimumPrice,
          priceMultiplier: multiplier,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.routes_createSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        _showError(context.l10n.routes_createError);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.routes_createTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    l10n.common_save,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origin and Destination
              _buildSectionTitle(context, l10n.routes_originDestination),
              const SizedBox(height: 12),

              // Origin City Dropdown
              SearchableCityDropdown(
                selectedCity: _originCity,
                onCitySelected: (city) {
                  setState(() => _originCity = city);
                },
                labelText: l10n.routes_originCity,
                hintText: l10n.routes_searchCity,
                prefixIcon: Icons.trip_origin,
                prefixIconColor: AppColors.success,
                filterCountries: const ['ES', 'UA', 'PL'],
                validator: (city) {
                  if (city == null) return l10n.routes_originRequired;
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Arrow indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_downward,
                    color: colors.textMuted,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Destination City Dropdown
              SearchableCityDropdown(
                selectedCity: _destinationCity,
                onCitySelected: (city) {
                  setState(() => _destinationCity = city);
                },
                labelText: l10n.routes_destinationCity,
                hintText: l10n.routes_searchCity,
                prefixIcon: Icons.location_on,
                prefixIconColor: AppColors.error,
                filterCountries: const ['ES', 'UA', 'PL'],
                validator: (city) {
                  if (city == null) return l10n.routes_destinationRequired;
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Stops Section
              MultiSelectCityChips(
                selectedCities: _stops,
                onCitiesChanged: (cities) {
                  setState(() => _stops = cities);
                },
                labelText: l10n.routes_stopsOptional,
                hintText: l10n.routes_searchCity,
                filterCountries: const ['ES', 'UA', 'PL'],
                excludeCities: [
                  if (_originCity != null) _originCity!,
                  if (_destinationCity != null) _destinationCity!,
                ],
              ),

              const SizedBox(height: 24),

              // Departure Dates Section
              _buildSectionTitle(context, l10n.routes_departureDates),
              const SizedBox(height: 4),
              Text(
                l10n.routes_departureDatesHint,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              // Selected dates chips
              SelectedDatesChips(
                dates: _selectedDepartureDates,
                onRemove: (date) {
                  setState(() {
                    _selectedDepartureDates.remove(date);
                  });
                },
              ),

              const SizedBox(height: 16),

              // Calendar
              MultiDateCalendar(
                selectedDates: _selectedDepartureDates,
                onDatesChanged: (dates) {
                  setState(() {
                    _selectedDepartureDates = dates;
                  });
                },
                firstAllowedDate: DateTime.now(),
              ),

              const SizedBox(height: 24),

              // Pricing Section
              _buildSectionTitle(context, l10n.routes_pricing),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Price per kg
                  Expanded(
                    child: TextFormField(
                      controller: _pricePerKgController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.routes_pricePerKg,
                        hintText: '0.00',
                        suffixText: 'EUR/kg',
                        filled: true,
                        fillColor: colors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Minimum price
                  Expanded(
                    child: TextFormField(
                      controller: _minimumPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.routes_minimumPrice,
                        hintText: '0.00',
                        suffixText: 'EUR',
                        filled: true,
                        fillColor: colors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Multiplier
              TextFormField(
                controller: _multiplierController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.routes_multiplier,
                  hintText: '1.0',
                  helperText: l10n.routes_multiplierHint,
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Trip Duration
              _buildSectionTitle(context, l10n.routes_tripDuration),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tripDurationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: l10n.routes_tripDurationHint,
                  prefixIcon: Icon(Icons.schedule, color: colors.textMuted),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.routes_tripDurationDescription,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedDepartureDates.isEmpty
                              ? l10n.routes_createButton
                              : l10n.routes_createButtonWithDates(_selectedDepartureDates.length),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
      ),
    );
  }
}
