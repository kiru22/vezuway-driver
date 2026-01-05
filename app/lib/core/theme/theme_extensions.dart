import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

/// Convenient BuildContext extension for accessing theme colors.
/// Usage: context.colors.cardBackground
extension ThemeExtensions on BuildContext {
  /// Access the custom color extension for semantic colors.
  /// Colors automatically adapt to light/dark theme.
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  /// Quick access to the current ThemeData
  ThemeData get theme => Theme.of(this);

  /// Quick access to the current ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
