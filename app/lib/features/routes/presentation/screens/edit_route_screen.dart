import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/models/city_model.dart';
import '../../../../shared/widgets/currency_dropdown.dart';
import '../../data/models/route_model.dart';
import '../../domain/providers/route_provider.dart';
import '../widgets/route_country_section.dart';
import '../widgets/route_form_widgets.dart';

class EditRouteScreen extends ConsumerStatefulWidget {
  final String routeId;

  const EditRouteScreen({super.key, required this.routeId});

  @override
  ConsumerState<EditRouteScreen> createState() => _EditRouteScreenState();
}

class _EditRouteScreenState extends ConsumerState<EditRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pricePerKgController = TextEditingController();
  final _minimumPriceController = TextEditingController();

  RouteSection _origin = RouteSection();
  final List<RouteSection> _intermediateStops = [];
  RouteSection _destination = RouteSection();
  String _currency = 'EUR';
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _pricePerKgController.dispose();
    _minimumPriceController.dispose();
    super.dispose();
  }

  void _initializeFromRoute(RouteModel route) {
    if (_isInitialized) return;
    _isInitialized = true;

    _origin = RouteSection(
      countryCode: route.originCountry,
      cities: [CityModel(name: route.origin, country: route.originCountry)],
    );

    _destination = RouteSection(
      countryCode: route.destinationCountry,
      cities: [
        CityModel(name: route.destination, country: route.destinationCountry)
      ],
    );

    if (route.stops.isNotEmpty) {
      final stopsByCountry = <String, List<CityModel>>{};
      for (final stop in route.stops) {
        final country = stop.country;
        if (country == route.originCountry) {
          _origin.cities.add(stop);
        } else if (country == route.destinationCountry) {
          _destination.cities.insert(_destination.cities.length - 1, stop);
        } else {
          stopsByCountry.putIfAbsent(country, () => []).add(stop);
        }
      }

      for (final entry in stopsByCountry.entries) {
        _intermediateStops.add(RouteSection(
          countryCode: entry.key,
          cities: entry.value,
        ));
      }
    }

    if (route.pricePerKg != null) {
      _pricePerKgController.text = route.pricePerKg!.toStringAsFixed(2);
    }
    if (route.minimumPrice != null) {
      _minimumPriceController.text = route.minimumPrice!.toStringAsFixed(2);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_origin.isValid) {
      _showError(context.l10n.routes_atLeastOneCity);
      return;
    }

    if (!_destination.isValid) {
      _showError(context.l10n.routes_atLeastOneCity);
      return;
    }

    setState(() => _isLoading = true);

    final allStops = buildStopsForBackend(
      origin: _origin,
      intermediateStops: _intermediateStops,
      destination: _destination,
    );

    final pricePerKg =
        double.tryParse(_pricePerKgController.text.replaceAll(',', '.'));
    final minimumPrice =
        double.tryParse(_minimumPriceController.text.replaceAll(',', '.'));

    final originCity = _origin.cities.first;
    final destinationCity = _destination.cities.last;

    final success = await ref.read(routesProvider.notifier).updateRoute(
          id: widget.routeId,
          origin: originCity.name,
          originCountry: originCity.country,
          destination: destinationCity.name,
          destinationCountry: destinationCity.country,
          stops: allStops.isNotEmpty ? allStops : [],
          pricePerKg: pricePerKg,
          minimumPrice: minimumPrice,
          priceMultiplier: 1.0,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.routes_updateSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        _showError(context.l10n.routes_updateError);
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

  void _addIntermediateStop() {
    HapticFeedback.lightImpact();
    setState(() {
      _intermediateStops.add(RouteSection());
    });
  }

  void _removeIntermediateStop(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _intermediateStops.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final routeAsync = ref.watch(routeDetailProvider(widget.routeId));

    return routeAsync.when(
      loading: () => _buildLoadingState(colors),
      error: (error, _) => _buildErrorState(colors, error),
      data: (route) {
        _initializeFromRoute(route);
        return _buildForm(colors, l10n);
      },
    );
  }

  Widget _buildLoadingState(AppColorsExtension colors) {
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(AppColorsExtension colors, Object error) {
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          'Error: $error',
          style: TextStyle(color: colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildForm(AppColorsExtension colors, AppLocalizations l10n) {
    final currencySymbol = getCurrencySymbol(_currency);

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
          l10n.routes_editTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildRouteDetailsHeader(colors, l10n),
                  const SizedBox(height: 16),
                  _buildTimeline(),
                  const SizedBox(height: 32),
                  _buildPricingSection(colors, l10n, currencySymbol),
                ],
              ),
            ),
            _buildBottomButton(colors, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteDetailsHeader(AppColorsExtension colors, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.routes_routeDetails,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
            letterSpacing: 1,
          ),
        ),
        GestureDetector(
          onTap: _addIntermediateStop,
          child: Text(
            l10n.routes_addCountry,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    final totalSections = 2 + _intermediateStops.length;

    return Column(
      children: [
        RouteTimelineItem(
          index: 0,
          totalSections: totalSections,
          type: RouteSectionType.origin,
          section: _origin,
          onSectionChanged: (section) => setState(() => _origin = section),
        ),
        for (int i = 0; i < _intermediateStops.length; i++)
          RouteTimelineItem(
            index: i + 1,
            totalSections: totalSections,
            type: RouteSectionType.intermediate,
            section: _intermediateStops[i],
            stopNumber: i + 1,
            onSectionChanged: (section) =>
                setState(() => _intermediateStops[i] = section),
            onDelete: () => _removeIntermediateStop(i),
          ),
        RouteTimelineItem(
          index: totalSections - 1,
          totalSections: totalSections,
          type: RouteSectionType.destination,
          section: _destination,
          onSectionChanged: (section) => setState(() => _destination = section),
        ),
      ],
    );
  }

  Widget _buildPricingSection(
    dynamic colors,
    dynamic l10n,
    String currencySymbol,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.routes_pricingSection,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RoutePriceField(
                      controller: _pricePerKgController,
                      label: l10n.routes_pricePerKg,
                      hint: '0.00',
                      suffix: '$currencySymbol/kg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoutePriceField(
                      controller: _minimumPriceController,
                      label: l10n.routes_minimumPrice,
                      hint: '0.00',
                      suffix: currencySymbol,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CurrencyDropdown(
                selectedCurrencyCode: _currency,
                onCurrencySelected: (code) {
                  setState(() => _currency = code);
                },
                labelText: l10n.routes_currency.toUpperCase(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(AppColorsExtension colors, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SizedBox(
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.common_save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
