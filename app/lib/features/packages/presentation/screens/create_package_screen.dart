import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/models/city_model.dart';
import '../../../../shared/utils/address_utils.dart';
import '../../../../shared/widgets/form_app_bar.dart';
import '../../data/models/package_model.dart';
import '../../domain/providers/package_provider.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../../routes/data/models/route_model.dart';
import '../../../ocr/presentation/widgets/ocr_scan_button.dart';
import '../widgets/package_image_gallery.dart';
import '../widgets/add_image_button.dart';
import '../../../../shared/widgets/styled_form_field.dart';

class CreatePackageScreen extends ConsumerStatefulWidget {
  final String? packageId;

  const CreatePackageScreen({super.key, this.packageId});

  bool get isEditMode => packageId != null;

  @override
  ConsumerState<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends ConsumerState<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedTabIndex = 1; // Default to receiver tab

  // Sender fields
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderExactAddressController = TextEditingController();
  final _senderGoogleMapsController = TextEditingController();
  CityModel? _senderCity;
  bool _senderShowAddress = false;

  // Receiver fields
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverExactAddressController = TextEditingController();
  final _receiverGoogleMapsController = TextEditingController();
  CityModel? _receiverCity;
  bool _receiverShowAddress = false;

  // Package details
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  RouteModel? _selectedRoute;
  double _volumetricWeight = 0.0;
  double _calculatedPrice = 0.0;
  double? _manualPrice; // Manually set price
  bool _isManualPrice = false; // Flag to track if price is manual
  bool _isLoading = false;

  // Lista de imágenes locales para enviar con el paquete
  final List<Uint8List> _packageImages = [];

  @override
  void initState() {
    super.initState();

    // Listeners for reactive price calculation
    for (final controller in [
      _weightController,
      _lengthController,
      _widthController,
      _heightController,
      _quantityController,
    ]) {
      controller.addListener(_updatePriceCalculation);
    }

    // Preselect route after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditMode) {
        _loadExistingPackage();
      } else {
        _preselectClosestRoute();
      }
    });
  }

  Future<void> _loadExistingPackage() async {
    if (widget.packageId == null) return;

    setState(() => _isLoading = true);

    try {
      final package = await ref.read(packageRepositoryProvider).getPackage(widget.packageId!);
      _populateFieldsFromPackage(package);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.packages_loadError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateFieldsFromPackage(PackageModel package) {
    // Sender fields
    _senderNameController.text = package.senderName;
    _senderPhoneController.text = package.senderPhone ?? '';
    // Parse address to extract city and exact address
    if (package.senderAddress != null) {
      _senderExactAddressController.text = package.senderAddress!;
      _senderShowAddress = package.senderAddress!.isNotEmpty;
    }

    // Receiver fields
    _receiverNameController.text = package.receiverName;
    _receiverPhoneController.text = package.receiverPhone ?? '';
    if (package.receiverAddress != null) {
      _receiverExactAddressController.text = package.receiverAddress!;
      _receiverShowAddress = package.receiverAddress!.isNotEmpty;
    }

    // Package details
    if (package.weight != null) {
      _weightController.text = package.weight.toString();
    }
    if (package.lengthCm != null) {
      _lengthController.text = package.lengthCm.toString();
    }
    if (package.widthCm != null) {
      _widthController.text = package.widthCm.toString();
    }
    if (package.heightCm != null) {
      _heightController.text = package.heightCm.toString();
    }
    if (package.quantity != null) {
      _quantityController.text = package.quantity.toString();
    }

    // Select route if assigned
    if (package.routeId != null) {
      final routesState = ref.read(routesProvider);
      final route = routesState.routes.where((r) => r.id == package.routeId).firstOrNull;
      if (route != null) {
        _selectedRoute = route;
      }
    }

    _updatePriceCalculation();
    setState(() {});
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    for (final controller in [
      _weightController,
      _lengthController,
      _widthController,
      _heightController,
      _quantityController,
    ]) {
      controller.removeListener(_updatePriceCalculation);
    }

    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderExactAddressController.dispose();
    _senderGoogleMapsController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverExactAddressController.dispose();
    _receiverGoogleMapsController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _preselectClosestRoute() {
    final routesState = ref.read(routesProvider);
    final availableRoutes = routesState.routes
        .where((r) => r.status == RouteStatus.planned || r.status == RouteStatus.inProgress)
        .where((r) => r.hasUpcomingDates)
        .toList()
      ..sort((a, b) => (a.nextDepartureDate ?? a.departureDate)
          .compareTo(b.nextDepartureDate ?? b.departureDate));

    if (availableRoutes.isNotEmpty) {
      setState(() {
        _selectedRoute = availableRoutes.first;
        _updatePriceCalculation();
      });
    }
  }

  double _calculateVolumetricWeight() {
    final length = double.tryParse(_lengthController.text) ?? 0;
    final width = double.tryParse(_widthController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (length <= 0 || width <= 0 || height <= 0) return 0;
    return (length * width * height) / 5000;
  }

  double _calculatePrice() {
    final route = _selectedRoute;
    if (route == null) return 0;

    final pricePerKg = route.pricePerKg;
    if (pricePerKg == null) return 0;

    final actualWeight = double.tryParse(_weightController.text) ?? 0;
    final volumetric = _calculateVolumetricWeight();
    final billingWeight = actualWeight > volumetric ? actualWeight : volumetric;

    final multiplier = route.priceMultiplier ?? 1.0;
    final minPrice = route.minimumPrice ?? 0;

    // Quantity is informational only, weight is already the total
    final calculatedPrice = billingWeight * pricePerKg * multiplier;
    return calculatedPrice > minPrice ? calculatedPrice : minPrice;
  }

  void _updatePriceCalculation() {
    setState(() {
      _volumetricWeight = _calculateVolumetricWeight();
      _calculatedPrice = _calculatePrice();
      // Don't override manual price with automatic calculation
    });
  }

  // Get the final price (manual or calculated)
  double get _finalPrice => _isManualPrice && _manualPrice != null ? _manualPrice! : _calculatedPrice;

  // Show dialog to edit price manually
  Future<void> _showPriceEditDialog() async {
    final controller = TextEditingController(
      text: _isManualPrice && _manualPrice != null
        ? _manualPrice!.toStringAsFixed(0)
        : _calculatedPrice.toStringAsFixed(0),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.l10n.packages_editPrice),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: dialogContext.l10n.packages_priceLabel,
              hintText: dialogContext.l10n.packages_priceHint,
              suffixText: '€',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.l10n.common_cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: Text(dialogContext.l10n.common_save),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final trimmed = result.trim();
    setState(() {
      if (trimmed.isEmpty) {
        // Empty input - switch back to automatic calculation
        _isManualPrice = false;
        _manualPrice = null;
        return;
      }

      // Manual price entered
      final price = double.tryParse(trimmed);
      if (price != null && price >= 0) {
        _isManualPrice = true;
        _manualPrice = price;
      }
    });
  }

  void _switchTab(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
  }

  void _applyOcrResult(String? name, String? phone, String? city, Uint8List? imageBytes) {
    setState(() {
      if (_selectedTabIndex == 0) {
        // Sender tab
        if (name != null) _senderNameController.text = name;
        if (phone != null) _senderPhoneController.text = phone;
        if (city != null) {
          _senderCity = _findCityByName(city);
        }
      } else {
        // Receiver tab
        if (name != null) _receiverNameController.text = name;
        if (phone != null) _receiverPhoneController.text = phone;
        if (city != null) {
          _receiverCity = _findCityByName(city);
        }
      }
      // Añadir la imagen escaneada a la galería
      if (imageBytes != null) {
        _packageImages.add(imageBytes);
      }
    });
  }

  CityModel? _findCityByName(String cityName) {
    final availableCities = _selectedRoute?.stops ?? [];
    final cityNameLower = cityName.toLowerCase();

    for (final city in availableCities) {
      if (city.name.toLowerCase() == cityNameLower ||
          city.nameEs.toLowerCase() == cityNameLower ||
          city.nameUk.toLowerCase() == cityNameLower) {
        return city;
      }
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.packages_routeRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate receiver city (sender is optional)
    if (_receiverCity == null) {
      setState(() => _selectedTabIndex = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.packages_cityRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      // Switch to receiver tab if validation error (receiver is required)
      if (_receiverNameController.text.isEmpty) {
        setState(() => _selectedTabIndex = 1);
      }
      return;
    }

    setState(() => _isLoading = true);

    final weight = double.tryParse(_weightController.text);
    final length = int.tryParse(_lengthController.text);
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);
    final quantity = int.tryParse(_quantityController.text);

    // Build full addresses combining city + exact address + Google Maps link
    final senderAddress = AddressUtils.buildAddressFromParts(
      cityName: _senderCity?.name,
      exactAddress: _senderExactAddressController.text.trim(),
      googleMapsLink: _senderGoogleMapsController.text.trim(),
    );
    final receiverAddress = AddressUtils.buildAddressFromParts(
      cityName: _receiverCity?.name,
      exactAddress: _receiverExactAddressController.text.trim(),
      googleMapsLink: _receiverGoogleMapsController.text.trim(),
    );

    final bool success;

    if (widget.isEditMode) {
      // Update existing package
      success = await ref.read(packagesProvider.notifier).updatePackage(
        id: widget.packageId!,
        routeId: _selectedRoute!.id,
        senderName: _senderNameController.text.trim(),
        senderPhone: _senderPhoneController.text.isNotEmpty
            ? _senderPhoneController.text.trim()
            : null,
        senderAddress: senderAddress,
        receiverName: _receiverNameController.text.trim(),
        receiverPhone: _receiverPhoneController.text.isNotEmpty
            ? _receiverPhoneController.text.trim()
            : null,
        receiverAddress: receiverAddress,
        weight: weight,
        lengthCm: length,
        widthCm: width,
        heightCm: height,
        quantity: quantity,
        declaredValue: _finalPrice > 0 ? _finalPrice : null,
      );

    } else {
      // Create new package
      success = await ref.read(packagesProvider.notifier).createPackage(
        routeId: _selectedRoute!.id,
        senderName: _senderNameController.text.trim(),
        senderPhone: _senderPhoneController.text.isNotEmpty
            ? _senderPhoneController.text.trim()
            : null,
        senderAddress: senderAddress,
        receiverName: _receiverNameController.text.trim(),
        receiverPhone: _receiverPhoneController.text.isNotEmpty
            ? _receiverPhoneController.text.trim()
            : null,
        receiverAddress: receiverAddress,
        weight: weight,
        lengthCm: length,
        widthCm: width,
        heightCm: height,
        quantity: quantity,
        declaredValue: _finalPrice > 0 ? _finalPrice : null,
        images: _packageImages.isNotEmpty ? _packageImages : null,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.packages_createSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        if (widget.isEditMode) {
          context.go('/packages/${widget.packageId}');
        } else {
          context.go('/packages');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(packagesProvider).error ?? context.l10n.packages_createError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var routes = ref.watch(routesProvider).routes
        .where((r) => r.status == RouteStatus.planned || r.status == RouteStatus.inProgress)
        .where((r) => r.hasUpcomingDates)
        .toList()
      ..sort((a, b) => (a.nextDepartureDate ?? a.departureDate)
          .compareTo(b.nextDepartureDate ?? b.departureDate));

    // En modo edición, asegurar que la ruta actual del paquete esté disponible
    // (aunque esté completada/cancelada o tenga fecha pasada)
    if (widget.isEditMode && _selectedRoute != null) {
      final currentRouteInList = routes.any((r) => r.id == _selectedRoute!.id);
      if (!currentRouteInList) {
        routes.insert(0, _selectedRoute!);
      }
    }

    // Solo mostrar estado vacío en modo CREACIÓN cuando no hay rutas
    // En modo EDICIÓN, permitir continuar (el paquete ya tiene ruta asignada)
    if (routes.isEmpty && !widget.isEditMode) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: colors.textPrimary),
            onPressed: () => context.go('/packages'),
          ),
        ),
        body: _buildEmptyRoutesState(colors),
      );
    }

    final isDark = context.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 750;

    return Scaffold(
      // Subtle gray background for light theme so white cards pop
      backgroundColor: isDark ? colors.surface : AppColors.lightInputBg,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(isCompact ? 12 : 20),
                children: [
                  // Route selector
                  _buildRouteSelector(routes, colors),
                  SizedBox(height: isCompact ? 12 : 20),

                  // Pill tabs for Sender/Receiver
                  _buildPillTabs(colors),
                  SizedBox(height: isCompact ? 8 : 16),

                  // Person form (changes based on tab)
                  _buildPersonForm(colors, isCompact),
                  SizedBox(height: isCompact ? 12 : 24),

                  // Price Calculator
                  _buildPriceCalculator(colors, isCompact),
                  SizedBox(height: isCompact ? 12 : 24),

                  // Sección de imágenes del paquete
                  _buildImagesSection(colors),
                  SizedBox(height: isCompact ? 12 : 24),
                ],
              ),
            ),

            // Submit button
            _buildSubmitButton(colors),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return FormAppBar(
      title: widget.isEditMode
          ? context.l10n.common_edit
          : context.l10n.packages_createTitle,
      onClose: () {
        if (widget.isEditMode) {
          context.go('/packages/${widget.packageId}');
        } else {
          context.go('/packages');
        }
      },
    );
  }

  Widget _buildEmptyRoutesState(AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.route_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.packages_noRoutesTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.packages_noRoutesMessage,
              style: TextStyle(
                fontSize: 14,
                color: colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/routes/create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.l10n.packages_createRouteButton,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelector(List<RouteModel> routes, AppColorsExtension colors) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRoute?.id,
          hint: Text(
            context.l10n.packages_selectRoute,
            style: TextStyle(
              color: isDark ? colors.textMuted : AppColors.lightTextSecondary,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
          ),
          dropdownColor: isDark ? colors.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: routes.map((route) => DropdownMenuItem<String>(
            value: route.id,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.route_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        route.name,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(route.nextDepartureDate ?? route.departureDate),
                        style: TextStyle(
                          color: isDark ? colors.textMuted : AppColors.lightTextMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (route.pricePerKg != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.lightAccentBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${route.pricePerKg!.toStringAsFixed(2)}€/kg',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          )).toList(),
          onChanged: (id) {
            setState(() {
              _selectedRoute = routes.firstWhere((r) => r.id == id);
              // Reset cities when route changes
              _senderCity = null;
              _receiverCity = null;
              _updatePriceCalculation();
            });
          },
        ),
      ),
    );
  }

  Widget _buildPillTabs(AppColorsExtension colors) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : AppColors.lightSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 4) / 2; // Account for gap

          return Stack(
            children: [
              // Sliding indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: _selectedTabIndex == 0 ? 0 : tabWidth + 4,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchTab(0),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: _selectedTabIndex == 0
                                  ? Colors.white
                                  : (isDark ? colors.textSecondary : AppColors.statusNeutralText),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            child: Text(context.l10n.packages_tabSender),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchTab(1),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: _selectedTabIndex == 1
                                  ? Colors.white
                                  : (isDark ? colors.textSecondary : AppColors.statusNeutralText),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            child: Text(context.l10n.packages_tabReceiver),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonForm(AppColorsExtension colors, bool isCompact) {
    final isSender = _selectedTabIndex == 0;
    final nameController = isSender ? _senderNameController : _receiverNameController;
    final phoneController = isSender ? _senderPhoneController : _receiverPhoneController;
    final exactAddressController = isSender ? _senderExactAddressController : _receiverExactAddressController;
    final googleMapsController = isSender ? _senderGoogleMapsController : _receiverGoogleMapsController;
    final selectedCity = isSender ? _senderCity : _receiverCity;
    final showAddress = isSender ? _senderShowAddress : _receiverShowAddress;
    final phoneHint = isSender ? context.l10n.packages_phoneHintSpain : context.l10n.packages_phoneHintUkraine;

    // Get available cities from route stops
    final availableCities = _selectedRoute?.stops ?? [];
    final gap = isCompact ? 8.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OCR scan button row
        Row(
          children: [
            Expanded(
              child: Text(
                isSender ? context.l10n.packages_tabSender : context.l10n.packages_tabReceiver,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
            OcrScanButton(onApply: _applyOcrResult),
          ],
        ),
        SizedBox(height: gap),

        // Name field (only required for receiver)
        StyledFormField(
          controller: nameController,
          label: context.l10n.packages_nameLabel,
          hint: isSender ? context.l10n.packages_senderNameHint : context.l10n.packages_receiverNameHint,
          prefixIcon: Icons.person_outline,
          validator: isSender
              ? null // Sender name is optional
              : (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.packages_nameRequired;
                  }
                  return null;
                },
        ),
        SizedBox(height: gap),

        // Phone field
        StyledFormField(
          controller: phoneController,
          label: context.l10n.packages_phoneLabel,
          hint: phoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: gap),

        // City dropdown + Address button row
        Row(
          children: [
            // City dropdown
            Expanded(
              child: _buildCityDropdown(
                selectedCity: selectedCity,
                cities: availableCities,
                colors: colors,
                onChanged: (city) {
                  setState(() {
                    if (isSender) {
                      _senderCity = city;
                    } else {
                      _receiverCity = city;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            // Address expand button
            SizedBox(
              height: 48,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (isSender) {
                      _senderShowAddress = !_senderShowAddress;
                    } else {
                      _receiverShowAddress = !_receiverShowAddress;
                    }
                  });
                },
                icon: Icon(
                  showAddress ? Icons.expand_less : Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                label: Text(
                  context.l10n.packages_addressButton,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Expandable address section
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandableAddressSection(
            exactAddressController: exactAddressController,
            googleMapsController: googleMapsController,
            colors: colors,
          ),
          crossFadeState: showAddress ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildCityDropdown({
    required CityModel? selectedCity,
    required List<CityModel> cities,
    required AppColorsExtension colors,
    required ValueChanged<CityModel?> onChanged,
  }) {
    // If no stops defined, show disabled text (cities come from route stops)
    if (cities.isEmpty) {
      final isDark = context.isDarkMode;
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? colors.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? colors.border : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_city_outlined,
              size: 20,
              color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCity?.name ?? context.l10n.packages_cityLabel,
                style: TextStyle(
                  color: selectedCity != null
                      ? colors.textPrimary
                      : (isDark ? colors.textMuted : AppColors.lightTextSecondary),
                  fontWeight: selectedCity != null ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isDark = context.isDarkMode;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CityModel>(
          value: selectedCity,
          hint: Row(
            children: [
              Icon(
                Icons.location_city_outlined,
                size: 20,
                color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.packages_cityLabel,
                style: TextStyle(
                  color: isDark ? colors.textMuted : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
          ),
          dropdownColor: isDark ? colors.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: cities.map((city) => DropdownMenuItem<CityModel>(
            value: city,
            child: Row(
              children: [
                Text(city.countryFlag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  city.name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildExpandableAddressSection({
    required TextEditingController exactAddressController,
    required TextEditingController googleMapsController,
    required AppColorsExtension colors,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            context.l10n.packages_deliverySection,
            style: TextStyle(
              color: isDark ? colors.textSecondary : AppColors.statusNeutralText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Exact address field
          StyledFormField(
            controller: exactAddressController,
            label: context.l10n.packages_exactAddress,
            hint: context.l10n.packages_deliveryAddressHint,
            prefixIcon: Icons.home_outlined,
          ),
          const SizedBox(height: 12),

          // Google Maps link field
          StyledFormField(
            controller: googleMapsController,
            label: context.l10n.packages_googleMapsLink,
            hint: 'https://maps.google.com/...',
            prefixIcon: Icons.map_outlined,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCalculator(AppColorsExtension colors, bool isCompact) {
    final pricePerKg = _selectedRoute?.pricePerKg;
    final hasPricing = pricePerKg != null;
    final billingWeight = _volumetricWeight > (double.tryParse(_weightController.text) ?? 0)
        ? _volumetricWeight
        : (double.tryParse(_weightController.text) ?? 0);
    final isDark = context.isDarkMode;
    final padding = isCompact ? 12.0 : 20.0;
    final gap = isCompact ? 10.0 : 20.0;
    final smallGap = isCompact ? 4.0 : 8.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight + Quantity row
          Row(
            children: [
              // Weight
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.packages_weightKg,
                      style: TextStyle(
                        color: isDark ? colors.textSecondary : AppColors.statusNeutralText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: smallGap),
                    _NumericInput(
                      controller: _weightController,
                      hint: '0.0',
                      allowDecimal: true,
                      isCompact: isCompact,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.packages_quantityPcs,
                      style: TextStyle(
                        color: isDark ? colors.textSecondary : AppColors.statusNeutralText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: smallGap),
                    _NumericInput(
                      controller: _quantityController,
                      hint: '1',
                      isCompact: isCompact,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: gap),

          // Dimensions label
          Text(
            context.l10n.packages_dimensionsCm,
            style: TextStyle(
              color: isDark ? colors.textSecondary : AppColors.statusNeutralText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: smallGap),

          // Dimensions row (L x W x H)
          Row(
            children: [
              Expanded(
                child: _DimensionInput(
                  controller: _lengthController,
                  label: context.l10n.packages_lengthLabel,
                  isCompact: isCompact,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: _DimensionInput(
                  controller: _widthController,
                  label: context.l10n.packages_widthLabel,
                  isCompact: isCompact,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: _DimensionInput(
                  controller: _heightController,
                  label: context.l10n.packages_heightLabel,
                  isCompact: isCompact,
                ),
              ),
            ],
          ),

          if (hasPricing) ...[
            SizedBox(height: gap),
            Divider(color: isDark ? colors.border : AppColors.lightBorder),
            SizedBox(height: isCompact ? 8 : 16),

            // Tariff info and total
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.l10n.packages_tariffLabel}: ${pricePerKg.toStringAsFixed(2)} €/kg',
                        style: TextStyle(
                          color: isDark ? colors.textSecondary : AppColors.lightTextSecondary,
                          fontSize: isCompact ? 12 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_volumetricWeight > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${context.l10n.packages_volumetricWeight}: ${_volumetricWeight.toStringAsFixed(2)} kg',
                            style: TextStyle(
                              color: isDark ? colors.textMuted : AppColors.lightTextMuted,
                              fontSize: isCompact ? 11 : 12,
                            ),
                          ),
                        ),
                      if (billingWeight > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${context.l10n.packages_billingWeight}: ${billingWeight.toStringAsFixed(2)} kg',
                            style: TextStyle(
                              color: isDark ? colors.textSecondary : AppColors.statusNeutralText,
                              fontSize: isCompact ? 12 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showPriceEditDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 12,
                      vertical: isCompact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isManualPrice
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: _isManualPrice
                          ? Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isManualPrice)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.edit_outlined,
                              size: isCompact ? 14 : 16,
                              color: AppColors.warning,
                            ),
                          ),
                        Text(
                          '${_finalPrice.toStringAsFixed(0)}€',
                          style: TextStyle(
                            color: _isManualPrice ? AppColors.warning : AppColors.primary,
                            fontSize: isCompact ? 18 : 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagesSection(AppColorsExtension colors) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 20,
                color: isDark ? colors.textSecondary : AppColors.statusNeutralText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.packages_imagesSection,
                  style: TextStyle(
                    color: isDark ? colors.textSecondary : AppColors.statusNeutralText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (_packageImages.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_packageImages.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_packageImages.isNotEmpty) ...[
            PackageImageGallery(
              localImages: _packageImages,
              editMode: true,
              onRemoveLocal: (index) {
                setState(() {
                  _packageImages.removeAt(index);
                });
              },
              height: 160,
            ),
            const SizedBox(height: 12),
          ],
          AddImageButton(
            compact: _packageImages.isEmpty,
            onImageSelected: (bytes) {
              setState(() {
                _packageImages.add(bytes);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppColorsExtension colors) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? colors.border : AppColors.lightBorder,
          ),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: _isLoading ? null : AppColors.primaryGradient,
              color: _isLoading ? AppColors.primary.withValues(alpha: 0.5) : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleSubmit,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.l10n.packages_submitPackage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Numeric input for weight/quantity - Clean minimal style with glow effect
class _NumericInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool allowDecimal;
  final bool isCompact;

  const _NumericInput({
    required this.controller,
    required this.hint,
    this.allowDecimal = false,
    this.isCompact = false,
  });

  @override
  State<_NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<_NumericInput> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final fontSize = widget.isCompact ? 22.0 : 28.0;
    final verticalPadding = widget.isCompact ? 6.0 : 12.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.numberWithOptions(decimal: widget.allowDecimal),
        textAlign: TextAlign.center,
        cursorWidth: 1.5,
        cursorColor: AppColors.primary,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: isDark ? colors.textMuted : AppColors.lightInputMuted,
            fontWeight: FontWeight.w400,
            fontSize: fontSize,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: verticalPadding),
        ),
        inputFormatters: [
          widget.allowDecimal
              ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
              : FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}

// Dimension input field (L/W/H) - Clean minimal style with glow effect
class _DimensionInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isCompact;

  const _DimensionInput({
    required this.controller,
    required this.label,
    this.isCompact = false,
  });

  @override
  State<_DimensionInput> createState() => _DimensionInputState();
}

class _DimensionInputState extends State<_DimensionInput> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final fontSize = widget.isCompact ? 18.0 : 24.0;
    final inputWidth = widget.isCompact ? 55.0 : 70.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: isDark ? colors.textSecondary : AppColors.lightTextMuted,
            fontSize: widget.isCompact ? 11 : 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: widget.isCompact ? 2 : 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: inputWidth,
          padding: EdgeInsets.symmetric(vertical: widget.isCompact ? 4 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            cursorWidth: 1.5,
            cursorColor: AppColors.primary,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              hintText: '0',
              hintStyle: TextStyle(
                color: isDark ? colors.textMuted : AppColors.lightInputMuted,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );
  }
}
