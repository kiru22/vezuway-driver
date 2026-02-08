import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/currency_dropdown.dart';
import '../../../../shared/widgets/form_app_bar.dart';
import '../../../../shared/widgets/submit_bottom_bar.dart';
import '../../../../shared/widgets/themed_card.dart';
import '../../domain/providers/route_provider.dart';
import '../widgets/route_country_section.dart';
import '../widgets/route_form_widgets.dart';

class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pricePerKgController = TextEditingController();
  final _minimumPriceController = TextEditingController();

  RouteSection _origin = RouteSection();
  final List<RouteSection> _intermediateStops = [];
  RouteSection _destination = RouteSection();
  String _currency = 'EUR';
  bool _isLoading = false;

  @override
  void dispose() {
    _pricePerKgController.dispose();
    _minimumPriceController.dispose();
    super.dispose();
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

    final success = await ref.read(routesProvider.notifier).createRoute(
          origin: originCity.name,
          originCountry: originCity.country,
          destination: destinationCity.name,
          destinationCountry: destinationCity.country,
          stops: allStops.isNotEmpty ? allStops : null,
          pricePerKg: pricePerKg,
          minimumPrice: minimumPrice,
          priceMultiplier: 1.0,
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
    final isDark = context.isDarkMode;
    final currencySymbol = getCurrencySymbol(_currency);

    return Scaffold(
      backgroundColor: isDark ? colors.background : AppColors.lightInputBg,
      appBar: FormAppBar(
        title: l10n.routes_createTitle,
        onClose: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildRouteDetailsHeader(colors, l10n),
                  const SizedBox(height: 16),
                  _buildTimeline(),
                  const SizedBox(height: 32),
                  _buildPricingSection(colors, l10n, currencySymbol),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SubmitBottomBar(
            onPressed: _isLoading ? null : _handleSubmit,
            label: l10n.routes_publishRoute,
            isLoading: _isLoading,
          ),
        ],
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
    AppColorsExtension colors,
    AppLocalizations l10n,
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
        ThemedCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
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

}
