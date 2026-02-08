import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../data/cities_data.dart';
import '../domain/providers/city_provider.dart';
import '../models/city_model.dart';

class SearchableCityDropdown extends ConsumerStatefulWidget {
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
  ConsumerState<SearchableCityDropdown> createState() =>
      _SearchableCityDropdownState();
}

class _SearchableCityDropdownState
    extends ConsumerState<SearchableCityDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  List<CityModel> _filteredCities = [];
  bool _isSearching = false;
  bool _isOpen = false;

  String _locale = 'es';

  @override
  void initState() {
    super.initState();
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
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _onSearchChanged(_controller.text);
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    if (_isOpen) return;
    _isOpen = true;

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
    _debounce?.cancel();

    if (query.length < 2) {
      setState(() {
        _isSearching = false;
        _filteredCities = CitiesData.searchCities(
          query,
          countries: widget.filterCountries,
        );
      });
      if (_focusNode.hasFocus) {
        _showOverlay();
      }
      _overlayEntry?.markNeedsBuild();
      return;
    }

    setState(() => _isSearching = true);
    _overlayEntry?.markNeedsBuild();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await ref.read(
          citySearchProvider(CitySearchParams(
            query: query,
            countries: widget.filterCountries,
          )).future,
        );

        if (mounted) {
          setState(() {
            _filteredCities = results;
            _isSearching = false;
          });

          if (_focusNode.hasFocus) {
            _showOverlay();
          }
          _overlayEntry?.markNeedsBuild();
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _filteredCities = CitiesData.searchCities(
              query,
              countries: widget.filterCountries,
            );
            _isSearching = false;
          });
          _overlayEntry?.markNeedsBuild();
        }
      }
    });
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

  Widget _buildOverlayContent(String noResultsText) {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_filteredCities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(noResultsText),
      );
    }

    return ListView.builder(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.getLocalizedName(_locale),
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                      Text(
                        city.region != null
                            ? '${city.getLocalizedCountry(_locale)} · ${city.region}'
                            : city.getLocalizedCountry(_locale),
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
    );
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
              child: _buildOverlayContent(noResultsText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuffixIcon() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 20),
        onPressed: _clearSelection,
      );
    }
    return const Icon(Icons.keyboard_arrow_down);
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
          suffixIcon: _buildSuffixIcon(),
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
