import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../data/cities_data.dart';
import '../models/city_model.dart';

class SearchableCityDropdown extends StatefulWidget {
  final CityModel? selectedCity;
  final ValueChanged<CityModel?> onCitySelected;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final String? Function(CityModel?)? validator;
  final List<String>? filterCountries;

  const SearchableCityDropdown({
    super.key,
    this.selectedCity,
    required this.onCitySelected,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.prefixIconColor,
    this.validator,
    this.filterCountries,
  });

  @override
  State<SearchableCityDropdown> createState() => _SearchableCityDropdownState();
}

class _SearchableCityDropdownState extends State<SearchableCityDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<CityModel> _filteredCities = [];
  bool _isOpen = false;

  String _locale = 'es';

  @override
  void initState() {
    super.initState();
    _filteredCities = CitiesData.searchCities(
      '',
      countries: widget.filterCountries,
    );
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = context.l10n.localeName;
    if (widget.selectedCity != null) {
      _controller.text = widget.selectedCity!.getLocalizedName(_locale);
    }
  }

  @override
  void didUpdateWidget(SearchableCityDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCity != oldWidget.selectedCity) {
      _controller.text = widget.selectedCity?.getLocalizedName(_locale) ?? '';
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      // Delay removal to allow tapping items in the overlay
      Future.delayed(const Duration(milliseconds: 200), () {
        // Check mounted to avoid accessing state after dispose
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    if (_isOpen) return;
    _isOpen = true;

    // Capture localization before creating overlay (overlay context may not have access)
    final noResultsText = context.l10n.common_noResults;
    _overlayEntry = _createOverlayEntry(noResultsText);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (!_isOpen) return;
    _isOpen = false;

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredCities = CitiesData.searchCities(
        query,
        countries: widget.filterCountries,
      );
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _selectCity(CityModel city) {
    _controller.text = city.getLocalizedName(_locale);
    widget.onCitySelected(city);
    _focusNode.unfocus();
    _removeOverlay();
  }

  void _clearSelection() {
    _controller.clear();
    widget.onCitySelected(null);
    _onSearchChanged('');
  }

  OverlayEntry _createOverlayEntry(String noResultsText) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: _filteredCities.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(noResultsText),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: _filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = _filteredCities[index];
                        final isSelected = city == widget.selectedCity;
                        return InkWell(
                          onTap: () => _selectCity(city),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : null,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        city.getLocalizedName(_locale),
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.primary
                                              : null,
                                        ),
                                      ),
                                      Text(
                                        city.getLocalizedCountry(_locale),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: widget.prefixIconColor ?? colors.textMuted,
                )
              : null,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearSelection,
                )
              : const Icon(Icons.keyboard_arrow_down),
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
        validator: widget.validator != null
            ? (_) => widget.validator!(widget.selectedCity)
            : null,
      ),
    );
  }
}
