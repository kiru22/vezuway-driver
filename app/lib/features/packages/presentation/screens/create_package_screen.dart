import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../trips/domain/providers/trip_provider.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../../trips/data/models/trip_status.dart';
import '../../../ocr/presentation/widgets/ocr_scan_button.dart';
import '../widgets/package_image_gallery.dart';
import '../widgets/add_image_button.dart';
import '../../../../shared/widgets/styled_form_field.dart';
import '../../../../shared/widgets/submit_bottom_bar.dart';
import '../../../contacts/data/models/contact_model.dart';
import '../../../contacts/presentation/widgets/contact_search_field.dart';

class CreatePackageScreen extends ConsumerStatefulWidget {
  final String? packageId;

  const CreatePackageScreen({super.key, this.packageId});

  bool get isEditMode => packageId != null;

  @override
  ConsumerState<CreatePackageScreen> createState() =>
      _CreatePackageScreenState();
}

class _CreatePackageScreenState extends ConsumerState<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedTabIndex = 1; // Default to receiver tab

  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderExactAddressController = TextEditingController();
  final _senderGoogleMapsController = TextEditingController();
  CityModel? _senderCity;
  bool _senderShowAddress = false;
  ContactModel? _selectedSenderContact;

  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverExactAddressController = TextEditingController();
  final _receiverGoogleMapsController = TextEditingController();
  final _novaPostNumberController = TextEditingController();
  CityModel? _receiverCity;
  bool _receiverShowAddress = false;
  ContactModel? _selectedReceiverContact;

  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();

  TripModel? _selectedTrip;
  double _volumetricWeight = 0.0;
  double _calculatedPrice = 0.0;
  double? _manualPrice; // Manually set price
  bool _isManualPrice = false; // Flag to track if price is manual
  bool _isLoading = false;

  final List<Uint8List> _packageImages = [];
  List<PackageImage> _existingImages = [];

  @override
  void initState() {
    super.initState();

    for (final controller in [
      _weightController,
      _lengthController,
      _widthController,
      _heightController,
      _quantityController,
    ]) {
      controller.addListener(_updatePriceCalculation);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditMode) {
        _loadExistingPackage();
      } else {
        _preselectClosestTrip();
      }
    });
  }

  Future<void> _loadExistingPackage() async {
    if (widget.packageId == null) return;

    setState(() => _isLoading = true);

    try {
      final package = await ref
          .read(packageRepositoryProvider)
          .getPackage(widget.packageId!);
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
    _senderNameController.text = package.senderName;
    _senderPhoneController.text = package.senderPhone ?? '';
    if (package.senderCity != null && package.senderCity!.isNotEmpty) {
      _senderCity = CityModel(
        name: package.senderCity!,
        country: package.senderCountry ?? 'UA',
      );
    }
    if (package.senderAddress != null && package.senderAddress!.isNotEmpty) {
      _senderExactAddressController.text = package.senderAddress!;
      _senderShowAddress = true;
    }

    _receiverNameController.text = package.receiverName;
    _receiverPhoneController.text = package.receiverPhone ?? '';
    if (package.receiverCity != null && package.receiverCity!.isNotEmpty) {
      _receiverCity = CityModel(
        name: package.receiverCity!,
        country: package.receiverCountry ?? 'ES',
      );
    }
    if (package.receiverAddress != null &&
        package.receiverAddress!.isNotEmpty) {
      _receiverExactAddressController.text = package.receiverAddress!;
      _receiverShowAddress = true;
    }

    if (package.novaPostNumber != null && package.novaPostNumber!.isNotEmpty) {
      _novaPostNumberController.text = package.novaPostNumber!;
      _receiverShowAddress = true;
    }

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

    if (package.tripId != null) {
      final tripsState = ref.read(tripsProvider);
      final trip =
          tripsState.trips.where((t) => t.id == package.tripId).firstOrNull;
      if (trip != null) {
        _selectedTrip = trip;
      }
    }

    _descriptionController.text = package.description ?? '';

    if (package.images.isNotEmpty) {
      _existingImages = List.from(package.images);
    }

    _updatePriceCalculation();
    setState(() {});
  }

  @override
  void dispose() {
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
    _novaPostNumberController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _preselectClosestTrip() {
    final tripsState = ref.read(tripsProvider);
    final availableTrips = tripsState.trips
        .where((t) =>
            t.status == TripStatus.planned || t.status == TripStatus.inProgress)
        .toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));

    if (availableTrips.isNotEmpty) {
      setState(() {
        _selectedTrip = availableTrips.first;
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

  /// Get available cities from the selected trip (origin, stops, destination)
  List<CityModel> _getAvailableCities() {
    final trip = _selectedTrip;
    if (trip == null) return [];

    final cities = <CityModel>[];

    // Add origin city
    cities.add(CityModel(
      name: trip.originCity,
      country: trip.originCountry,
    ));

    // Add stop cities
    for (final stop in trip.stops) {
      cities.add(CityModel(
        name: stop.city,
        country: stop.country,
      ));
    }

    // Add destination city
    cities.add(CityModel(
      name: trip.destinationCity,
      country: trip.destinationCountry,
    ));

    return cities;
  }

  double _calculatePrice() {
    final trip = _selectedTrip;
    if (trip == null) return 0;

    final pricePerKg = trip.pricePerKg;
    if (pricePerKg == null) return 0;

    final actualWeight = double.tryParse(_weightController.text) ?? 0;
    final volumetric = _calculateVolumetricWeight();
    final billingWeight = actualWeight > volumetric ? actualWeight : volumetric;

    final multiplier = trip.priceMultiplier ?? 1.0;
    final minPrice = trip.minimumPrice ?? 0;

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

  double get _finalPrice =>
      _isManualPrice && _manualPrice != null ? _manualPrice! : _calculatedPrice;

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

  void _applyOcrResult(
      String? name, String? phone, String? city, Uint8List? imageBytes) {
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
      if (imageBytes != null) {
        _packageImages.add(imageBytes);
      }
    });
  }

  CityModel? _findCityByName(String cityName) {
    final availableCities = _getAvailableCities();
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

  Future<void> _handleRemoveExistingImage(String mediaId) async {
    if (!widget.isEditMode || widget.packageId == null) return;

    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.packages_deleteImageTitle),
        content: Text(l10n.packages_deleteImageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repository = ref.read(packageRepositoryProvider);
      await repository.deleteImage(widget.packageId!, mediaId);
      setState(() {
        _existingImages.removeWhere((img) => img.id == mediaId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.packages_imageError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedTrip == null) {
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

    // Build addresses combining exact address + Google Maps link (city is separate)
    final senderAddress = AddressUtils.buildAddressFromParts(
      exactAddress: _senderExactAddressController.text.trim(),
      googleMapsLink: _senderGoogleMapsController.text.trim(),
    );
    final receiverAddress = AddressUtils.buildAddressFromParts(
      exactAddress: _receiverExactAddressController.text.trim(),
      googleMapsLink: _receiverGoogleMapsController.text.trim(),
    );

    // Common fields shared between create and update
    String? trimOrNull(TextEditingController c) =>
        c.text.isNotEmpty ? c.text.trim() : null;

    final notifier = ref.read(packagesProvider.notifier);
    final bool success;

    if (widget.isEditMode) {
      success = await notifier.updatePackage(
            id: widget.packageId!,
            tripId: _selectedTrip!.id,
            senderContactId: _selectedSenderContact?.id,
            receiverContactId: _selectedReceiverContact?.id,
            senderName: _senderNameController.text.trim(),
            senderPhone: trimOrNull(_senderPhoneController),
            senderCity: _senderCity?.name,
            senderCountry: _senderCity?.country,
            senderAddress: senderAddress.isNotEmpty ? senderAddress : null,
            receiverName: _receiverNameController.text.trim(),
            receiverPhone: trimOrNull(_receiverPhoneController),
            receiverCity: _receiverCity?.name,
            receiverCountry: _receiverCity?.country,
            receiverAddress:
                receiverAddress.isNotEmpty ? receiverAddress : null,
            weight: weight,
            lengthCm: length,
            widthCm: width,
            heightCm: height,
            quantity: quantity,
            declaredValue: _finalPrice > 0 ? _finalPrice : null,
            description: trimOrNull(_descriptionController),
            novaPostNumber: trimOrNull(_novaPostNumberController),
          );
    } else {
      success = await notifier.createPackage(
            tripId: _selectedTrip!.id,
            senderContactId: _selectedSenderContact?.id,
            receiverContactId: _selectedReceiverContact?.id,
            senderName: _senderNameController.text.trim(),
            senderPhone: trimOrNull(_senderPhoneController),
            senderCity: _senderCity?.name,
            senderCountry: _senderCity?.country,
            senderAddress: senderAddress.isNotEmpty ? senderAddress : null,
            receiverName: _receiverNameController.text.trim(),
            receiverPhone: trimOrNull(_receiverPhoneController),
            receiverCity: _receiverCity?.name,
            receiverCountry: _receiverCity?.country,
            receiverAddress:
                receiverAddress.isNotEmpty ? receiverAddress : null,
            weight: weight,
            lengthCm: length,
            widthCm: width,
            heightCm: height,
            quantity: quantity,
            declaredValue: _finalPrice > 0 ? _finalPrice : null,
            description: trimOrNull(_descriptionController),
            novaPostNumber: trimOrNull(_novaPostNumberController),
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
            content: Text(ref.read(packagesProvider).error ??
                context.l10n.packages_createError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var trips = ref
        .watch(tripsProvider)
        .trips
        .where((t) =>
            t.status == TripStatus.planned || t.status == TripStatus.inProgress)
        .toList()
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));

    // En modo edición, asegurar que el viaje actual del paquete esté disponible
    // (aunque esté completado/cancelado o tenga fecha pasada)
    if (widget.isEditMode && _selectedTrip != null) {
      final currentTripInList = trips.any((t) => t.id == _selectedTrip!.id);
      if (!currentTripInList) {
        trips.insert(0, _selectedTrip!);
      }
    }

    // Solo mostrar estado vacío en modo CREACIÓN cuando no hay viajes
    // En modo EDICIÓN, permitir continuar (el paquete ya tiene viaje asignado)
    if (trips.isEmpty && !widget.isEditMode) {
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
        body: _buildEmptyTripsState(colors),
      );
    }

    final isDark = context.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 850;
    final isUltraCompact = screenHeight < 700;

    return Scaffold(
      // Subtle tonal difference: darker bg so cards/inputs pop
      backgroundColor: isDark ? colors.background : AppColors.lightInputBg,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewH = constraints.maxHeight;
                  final pad = isCompact ? 8.0 : 20.0;

                  // Interpolate gaps based on available viewport height
                  final rangeStart = isCompact ? 450.0 : 600.0;
                  final rangeSize = isCompact ? 150.0 : 200.0;
                  final t = ((viewH - rangeStart) / rangeSize).clamp(0.0, 1.0);

                  final sectionGap = isCompact
                      ? 6.0 + 18.0 * t   // 6→24
                      : 16.0 + 16.0 * t;  // 16→32
                  final intraGap = isCompact
                      ? 4.0 + 8.0 * t     // 4→12
                      : 12.0 + 8.0 * t;   // 12→20

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTripSelector(trips, colors),
                        SizedBox(height: intraGap),

                        _buildPillTabs(colors, isUltraCompact: isUltraCompact),
                        SizedBox(height: sectionGap),

                        _buildPersonForm(colors, isCompact, isUltraCompact: isUltraCompact),
                        SizedBox(height: sectionGap),

                        _buildPriceCalculator(colors, isCompact, isUltraCompact: isUltraCompact),
                        SizedBox(height: sectionGap),

                        StyledFormField(
                          controller: _descriptionController,
                          label: context.l10n.packageDescription,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                        SizedBox(height: sectionGap),

                        _buildImagesSection(colors),
                        SizedBox(height: 6),
                      ],
                    ),
                  );
                },
              ),
            ),

            SubmitBottomBar(
              onPressed: _isLoading ? null : _handleSubmit,
              label: context.l10n.packages_submitPackage,
              isLoading: _isLoading,
            ),
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

  Widget _buildEmptyTripsState(AppColorsExtension colors) {
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
                onPressed: () => context.push('/trips/create'),
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

  Widget _buildTripSelector(List<TripModel> trips, AppColorsExtension colors) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTrip?.id,
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
          items: trips
              .map((trip) => DropdownMenuItem<String>(
                    value: trip.id,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.route_rounded,
                              size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                trip.displayName,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(trip.departureDate),
                                style: TextStyle(
                                  color: isDark
                                      ? colors.textMuted
                                      : AppColors.lightTextMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (trip.pricePerKg != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.lightAccentBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${trip.pricePerKg!.toStringAsFixed(2)}€/kg',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (id) {
            setState(() {
              _selectedTrip = trips.firstWhere((t) => t.id == id);
              // Reset cities when trip changes
              _senderCity = null;
              _receiverCity = null;
              _updatePriceCalculation();
            });
          },
        ),
      ),
    );
  }

  Widget _buildPillTabs(AppColorsExtension colors, {bool isUltraCompact = false}) {
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
              Row(
                children: [
                  _buildTabLabel(0, context.l10n.packages_tabSender, isDark, colors, isUltraCompact),
                  const SizedBox(width: 4),
                  _buildTabLabel(1, context.l10n.packages_tabReceiver, isDark, colors, isUltraCompact),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabLabel(int index, String label, bool isDark, AppColorsExtension colors, bool isUltraCompact) {
    final isActive = _selectedTabIndex == index;
    final inactiveColor = isDark ? colors.textSecondary : AppColors.statusNeutralText;

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isUltraCompact ? 8 : 14),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? Colors.white : inactiveColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonForm(AppColorsExtension colors, bool isCompact, {bool isUltraCompact = false}) {
    final isSender = _selectedTabIndex == 0;
    final nameController =
        isSender ? _senderNameController : _receiverNameController;
    final phoneController =
        isSender ? _senderPhoneController : _receiverPhoneController;
    final exactAddressController = isSender
        ? _senderExactAddressController
        : _receiverExactAddressController;
    final googleMapsController =
        isSender ? _senderGoogleMapsController : _receiverGoogleMapsController;
    final selectedCity = isSender ? _senderCity : _receiverCity;
    final showAddress = isSender ? _senderShowAddress : _receiverShowAddress;
    final phoneHint = isSender
        ? context.l10n.packages_phoneHintSpain
        : context.l10n.packages_phoneHintUkraine;

    final availableCities = _getAvailableCities();
    final gap = isUltraCompact ? 4.0 : (isCompact ? 8.0 : 12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isSender
                    ? context.l10n.packages_tabSender
                    : context.l10n.packages_tabReceiver,
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

        ContactSearchField(
          key: ValueKey('contact_search_$_selectedTabIndex'),
          controller: nameController,
          label: context.l10n.packages_nameLabel,
          hintText: isSender
              ? context.l10n.packages_senderNameHint
              : context.l10n.packages_receiverNameHint,
          icon: Icons.person_outline,
          dense: isUltraCompact,
          onContactSelected: (contact) {
            setState(() {
              if (isSender) {
                _selectedSenderContact = contact;
                _senderNameController.text = contact.name;
                _senderPhoneController.text = contact.phone ?? '';
                if (contact.city != null) {
                  _senderCity = CityModel(
                    name: contact.city!,
                    country: contact.country ?? 'UA',
                  );
                }
                if (contact.address != null) {
                  _senderExactAddressController.text = contact.address!;
                  _senderShowAddress = true;
                }
              } else {
                _selectedReceiverContact = contact;
                _receiverNameController.text = contact.name;
                _receiverPhoneController.text = contact.phone ?? '';
                if (contact.city != null) {
                  _receiverCity = CityModel(
                    name: contact.city!,
                    country: contact.country ?? 'ES',
                  );
                }
                if (contact.address != null) {
                  _receiverExactAddressController.text = contact.address!;
                  _receiverShowAddress = true;
                }
              }
            });
          },
          onManualEntry: (name) {
            setState(() {
              if (isSender) {
                _selectedSenderContact = null;
              } else {
                _selectedReceiverContact = null;
              }
            });
          },
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

        StyledFormField(
          controller: phoneController,
          label: context.l10n.packages_phoneLabel,
          hint: phoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          dense: isUltraCompact,
        ),
        SizedBox(height: gap),

        Row(
          children: [
            Expanded(
              child: _buildCityDropdown(
                selectedCity: selectedCity,
                cities: availableCities,
                colors: colors,
                isUltraCompact: isUltraCompact,
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
            SizedBox(
              height: isUltraCompact ? 40 : 48,
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

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandableAddressSection(
            exactAddressController: exactAddressController,
            googleMapsController: googleMapsController,
            colors: colors,
            isUkraine: !isSender && _receiverCity?.country == 'UA',
          ),
          crossFadeState: showAddress
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
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
    bool isUltraCompact = false,
  }) {
    // If no stops defined, show disabled text (cities come from route stops)
    if (cities.isEmpty) {
      final isDark = context.isDarkMode;
      return Container(
        height: isUltraCompact ? 40 : 48,
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
              color:
                  isDark ? colors.textSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCity?.name ?? context.l10n.packages_cityLabel,
                style: TextStyle(
                  color: selectedCity != null
                      ? colors.textPrimary
                      : (isDark
                          ? colors.textMuted
                          : AppColors.lightTextSecondary),
                  fontWeight:
                      selectedCity != null ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isDark = context.isDarkMode;

    // Ensure selectedCity is in the list; if not, find match by name
    var resolvedCity = selectedCity;
    if (resolvedCity != null && !cities.contains(resolvedCity)) {
      resolvedCity = cities
          .where((c) => c.name == resolvedCity!.name)
          .firstOrNull;
    }

    return Container(
      height: isUltraCompact ? 40 : 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CityModel>(
          value: resolvedCity,
          hint: Row(
            children: [
              Icon(
                Icons.location_city_outlined,
                size: 20,
                color: isDark
                    ? colors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.packages_cityLabel,
                style: TextStyle(
                  color:
                      isDark ? colors.textMuted : AppColors.lightTextSecondary,
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
          items: cities
              .map((city) => DropdownMenuItem<CityModel>(
                    value: city,
                    child: Row(
                      children: [
                        Text(city.countryFlag,
                            style: const TextStyle(fontSize: 18)),
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
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildExpandableAddressSection({
    required TextEditingController exactAddressController,
    required TextEditingController googleMapsController,
    required AppColorsExtension colors,
    bool isUkraine = false,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.background : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.border : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.packages_deliverySection,
            style: TextStyle(
              color:
                  isDark ? colors.textSecondary : AppColors.statusNeutralText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          StyledFormField(
            controller: exactAddressController,
            label: context.l10n.packages_exactAddress,
            hint: context.l10n.packages_deliveryAddressHint,
            prefixIcon: Icons.home_outlined,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: StyledFormField(
                  controller: googleMapsController,
                  label: context.l10n.packages_googleMapsLink,
                  hint: 'https://maps.google.com/...',
                  prefixIcon: Icons.map_outlined,
                  keyboardType: TextInputType.url,
                ),
              ),
              if (isUkraine) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: StyledFormField(
                    controller: _novaPostNumberController,
                    label: context.l10n.packages_novaPostNumber,
                    hint: '123',
                    prefixWidget: SvgPicture.asset(
                      'assets/icons/nova_post.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFE3000F),
                        BlendMode.srcIn,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCalculator(AppColorsExtension colors, bool isCompact, {bool isUltraCompact = false}) {
    final pricePerKg = _selectedTrip?.pricePerKg;
    final hasPricing = pricePerKg != null;
    final billingWeight =
        _volumetricWeight > (double.tryParse(_weightController.text) ?? 0)
            ? _volumetricWeight
            : (double.tryParse(_weightController.text) ?? 0);
    final isDark = context.isDarkMode;
    final padding = isUltraCompact ? 8.0 : (isCompact ? 12.0 : 20.0);
    final gap = isUltraCompact ? 6.0 : (isCompact ? 10.0 : 20.0);
    final smallGap = isUltraCompact ? 2.0 : (isCompact ? 4.0 : 8.0);

    return Container(
      padding: EdgeInsets.all(padding),
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
          if (!isUltraCompact) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.packages_weightKg,
                        style: TextStyle(
                          color: isDark
                              ? colors.textSecondary
                              : AppColors.statusNeutralText,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.packages_quantityPcs,
                        style: TextStyle(
                          color: isDark
                              ? colors.textSecondary
                              : AppColors.statusNeutralText,
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
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _NumericInput(
                    controller: _weightController,
                    hint: 'kg',
                    allowDecimal: true,
                    isCompact: true,
                    isUltraCompact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumericInput(
                    controller: _quantityController,
                    hint: 'uds',
                    isCompact: true,
                    isUltraCompact: true,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: gap),

          if (!isUltraCompact) ...[
            Text(
              context.l10n.packages_dimensionsCm,
              style: TextStyle(
                color:
                    isDark ? colors.textSecondary : AppColors.statusNeutralText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: smallGap),
          ],

          Row(
            children: [
              Expanded(
                child: _DimensionInput(
                  controller: _lengthController,
                  label: context.l10n.packages_lengthLabel,
                  isCompact: isCompact,
                  isUltraCompact: isUltraCompact,
                ),
              ),
              SizedBox(width: isUltraCompact ? 8 : (isCompact ? 10 : 12)),
              Expanded(
                child: _DimensionInput(
                  controller: _widthController,
                  label: context.l10n.packages_widthLabel,
                  isCompact: isCompact,
                  isUltraCompact: isUltraCompact,
                ),
              ),
              SizedBox(width: isUltraCompact ? 8 : (isCompact ? 10 : 12)),
              Expanded(
                child: _DimensionInput(
                  controller: _heightController,
                  label: context.l10n.packages_heightLabel,
                  isCompact: isCompact,
                  isUltraCompact: isUltraCompact,
                ),
              ),
            ],
          ),

          if (hasPricing) ...[
            SizedBox(height: gap),
            Divider(color: isDark ? colors.border : AppColors.lightBorder),
            SizedBox(height: isUltraCompact ? 4 : (isCompact ? 8 : 16)),

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
                          color: isDark
                              ? colors.textSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: isUltraCompact ? 11 : (isCompact ? 12 : 13),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_volumetricWeight > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${context.l10n.packages_volumetricWeight}: ${_volumetricWeight.toStringAsFixed(2)} kg',
                            style: TextStyle(
                              color: isDark
                                  ? colors.textMuted
                                  : AppColors.lightTextMuted,
                              fontSize: isUltraCompact ? 10 : (isCompact ? 11 : 12),
                            ),
                          ),
                        ),
                      if (billingWeight > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${context.l10n.packages_billingWeight}: ${billingWeight.toStringAsFixed(2)} kg',
                            style: TextStyle(
                              color: isDark
                                  ? colors.textSecondary
                                  : AppColors.statusNeutralText,
                              fontSize: isUltraCompact ? 11 : (isCompact ? 12 : 13),
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
                      horizontal: 12,
                      vertical: isCompact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isManualPrice
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: _isManualPrice
                          ? Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                              width: 1.5)
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
                              size: isUltraCompact ? 12 : (isCompact ? 14 : 16),
                              color: AppColors.warning,
                            ),
                          ),
                        Text(
                          '${_finalPrice.toStringAsFixed(0)}€',
                          style: TextStyle(
                            color: _isManualPrice
                                ? AppColors.warning
                                : AppColors.primary,
                            fontSize: 22,
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
                color:
                    isDark ? colors.textSecondary : AppColors.statusNeutralText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.packages_imagesSection,
                  style: TextStyle(
                    color: isDark
                        ? colors.textSecondary
                        : AppColors.statusNeutralText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (_packageImages.isNotEmpty || _existingImages.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_packageImages.length + _existingImages.length}',
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
          if (_packageImages.isNotEmpty || _existingImages.isNotEmpty) ...[
            PackageImageGallery(
              localImages: _packageImages,
              remoteImages: _existingImages,
              editMode: true,
              onRemoveLocal: (index) {
                setState(() {
                  _packageImages.removeAt(index);
                });
              },
              onRemoveRemote: (mediaId) => _handleRemoveExistingImage(mediaId),
              height: 160,
            ),
            const SizedBox(height: 12),
          ],
          AddImageButton(
            compact: _packageImages.isEmpty && _existingImages.isEmpty,
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

}

// Numeric input for weight/quantity - Clean minimal style with glow effect
class _NumericInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool allowDecimal;
  final bool isCompact;
  final bool isUltraCompact;

  const _NumericInput({
    required this.controller,
    required this.hint,
    this.allowDecimal = false,
    this.isCompact = false,
    this.isUltraCompact = false,
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
    final fontSize = widget.isUltraCompact ? 18.0 : (widget.isCompact ? 22.0 : 28.0);
    final verticalPadding = widget.isUltraCompact ? 2.0 : (widget.isCompact ? 6.0 : 12.0);

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
        keyboardType:
            TextInputType.numberWithOptions(decimal: widget.allowDecimal),
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
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8, vertical: verticalPadding),
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
  final bool isUltraCompact;

  const _DimensionInput({
    required this.controller,
    required this.label,
    this.isCompact = false,
    this.isUltraCompact = false,
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
    final isAnyCompact = widget.isUltraCompact || widget.isCompact;
    final fontSize = isAnyCompact ? 15.0 : 18.0;
    final inputHeight = isAnyCompact ? 48.0 : 52.0;
    final hMargin = widget.isUltraCompact ? 6.0 : (widget.isCompact ? 4.0 : 2.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: inputHeight,
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
            child: Center(
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
                  filled: true,
                  fillColor: isDark ? colors.surface : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? colors.border : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? colors.border : AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                  hintText: widget.label,
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
          ),
        ],
      ),
    );
  }
}
