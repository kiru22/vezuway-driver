import 'package:flutter/material.dart';
import '../../../../shared/models/city_model.dart';

/// Holds form state for a contact (sender or receiver).
///
/// Groups related TextEditingControllers and state flags
/// for a single contact entry in the package form.
class ContactFormState {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController exactAddress = TextEditingController();
  final TextEditingController googleMaps = TextEditingController();

  CityModel? city;
  bool showAddress = false;

  /// Disposes all controllers. Call this in the parent widget's dispose().
  void dispose() {
    name.dispose();
    phone.dispose();
    exactAddress.dispose();
    googleMaps.dispose();
  }

  /// Populates fields from existing data (for edit mode).
  void populateFrom({
    String? name,
    String? phone,
    String? address,
  }) {
    if (name != null) this.name.text = name;
    if (phone != null) this.phone.text = phone;
    if (address != null) {
      exactAddress.text = address;
      showAddress = address.isNotEmpty;
    }
  }

  /// Clears all fields.
  void clear() {
    name.clear();
    phone.clear();
    exactAddress.clear();
    googleMaps.clear();
    city = null;
    showAddress = false;
  }

  /// Returns trimmed name text.
  String get nameText => name.text.trim();

  /// Returns trimmed phone text or null if empty.
  String? get phoneText {
    final text = phone.text.trim();
    return text.isNotEmpty ? text : null;
  }

  /// Returns trimmed exact address text.
  String get exactAddressText => exactAddress.text.trim();

  /// Returns trimmed Google Maps link text.
  String get googleMapsText => googleMaps.text.trim();
}

/// Holds form state for package dimensions and quantity.
///
/// Groups weight, dimensions, and quantity controllers with
/// helper methods for price calculation.
class DimensionsFormState {
  final TextEditingController weight = TextEditingController();
  final TextEditingController length = TextEditingController();
  final TextEditingController width = TextEditingController();
  final TextEditingController height = TextEditingController();
  final TextEditingController quantity = TextEditingController(text: '1');

  /// Disposes all controllers. Call this in the parent widget's dispose().
  void dispose() {
    weight.dispose();
    length.dispose();
    width.dispose();
    height.dispose();
    quantity.dispose();
  }

  /// Adds a listener to all dimension controllers (for price updates).
  void addPriceListener(VoidCallback callback) {
    for (final c in [weight, length, width, height, quantity]) {
      c.addListener(callback);
    }
  }

  /// Removes a listener from all dimension controllers.
  void removePriceListener(VoidCallback callback) {
    for (final c in [weight, length, width, height, quantity]) {
      c.removeListener(callback);
    }
  }

  /// Populates fields from existing data (for edit mode).
  void populateFrom({
    double? weight,
    int? length,
    int? width,
    int? height,
    int? quantity,
  }) {
    if (weight != null) this.weight.text = weight.toString();
    if (length != null) this.length.text = length.toString();
    if (width != null) this.width.text = width.toString();
    if (height != null) this.height.text = height.toString();
    if (quantity != null) this.quantity.text = quantity.toString();
  }

  /// Parsed weight value or null.
  double? get weightValue => double.tryParse(weight.text);

  /// Parsed length value or null.
  int? get lengthValue => int.tryParse(length.text);

  /// Parsed width value or null.
  int? get widthValue => int.tryParse(width.text);

  /// Parsed height value or null.
  int? get heightValue => int.tryParse(height.text);

  /// Parsed quantity value or null.
  int? get quantityValue => int.tryParse(quantity.text);
}
