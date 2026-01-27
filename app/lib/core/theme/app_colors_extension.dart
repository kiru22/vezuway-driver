import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ThemeExtension for semantic colors that automatically adapt to light/dark theme.
/// Usage: context.colors.cardBackground
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Backgrounds
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color surfaceElevated;
  final Color cardBackground;
  final Color cardBackgroundElevated;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Borders
  final Color border;
  final Color borderLight;
  final Color borderAccent;
  final Color divider;

  // Navigation
  final Color navBackground;
  final Color navItemInactive;

  // Chips - Orange
  final Color chipOrange;
  final Color chipOrangeText;
  final Color chipOrangeBorder;

  // Chips - Blue
  final Color chipBlue;
  final Color chipBlueText;
  final Color chipBlueBorder;

  // Chips - Green
  final Color chipGreen;
  final Color chipGreenText;
  final Color chipGreenBorder;

  // Chips - Gray
  final Color chipGray;
  final Color chipGrayText;
  final Color chipGrayBorder;

  // Shadows & Effects
  final Color shadow;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.surfaceElevated,
    required this.cardBackground,
    required this.cardBackgroundElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderLight,
    required this.borderAccent,
    required this.divider,
    required this.navBackground,
    required this.navItemInactive,
    required this.chipOrange,
    required this.chipOrangeText,
    required this.chipOrangeBorder,
    required this.chipBlue,
    required this.chipBlueText,
    required this.chipBlueBorder,
    required this.chipGreen,
    required this.chipGreenText,
    required this.chipGreenBorder,
    required this.chipGray,
    required this.chipGrayText,
    required this.chipGrayBorder,
    required this.shadow,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  /// Dark theme colors
  static const dark = AppColorsExtension(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceLight: AppColors.surfaceLight,
    surfaceElevated: AppColors.surfaceElevated,
    cardBackground: AppColors.cardBackground,
    cardBackgroundElevated: AppColors.cardBackgroundElevated,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    border: AppColors.border,
    borderLight: AppColors.borderLight,
    borderAccent: AppColors.borderAccent,
    divider: AppColors.divider,
    navBackground: AppColors.navBackground,
    navItemInactive: AppColors.navItemInactive,
    chipOrange: AppColors.chipOrange,
    chipOrangeText: AppColors.chipOrangeText,
    chipOrangeBorder: AppColors.chipOrangeBorder,
    chipBlue: AppColors.chipBlue,
    chipBlueText: AppColors.chipBlueText,
    chipBlueBorder: AppColors.chipBlueBorder,
    chipGreen: AppColors.chipGreen,
    chipGreenText: AppColors.chipGreenText,
    chipGreenBorder: AppColors.chipGreenBorder,
    chipGray: AppColors.chipGray,
    chipGrayText: AppColors.chipGrayText,
    chipGrayBorder: AppColors.chipGrayBorder,
    shadow: AppColors.shadow,
    shimmerBase: AppColors.shimmerBase,
    shimmerHighlight: AppColors.shimmerHighlight,
  );

  /// Light theme colors
  static const light = AppColorsExtension(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceLight: AppColors.lightSurfaceLight,
    surfaceElevated: AppColors.lightSurfaceElevated,
    cardBackground: AppColors.lightCardBackground,
    cardBackgroundElevated: AppColors.lightCardBackground,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    border: AppColors.lightBorder,
    borderLight: AppColors.lightBorderLight,
    borderAccent: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    navBackground: AppColors.lightNavBackground,
    navItemInactive: AppColors.lightNavItemInactive,
    chipOrange: AppColors.lightChipOrange,
    chipOrangeText: AppColors.lightChipOrangeText,
    chipOrangeBorder: AppColors.lightChipOrangeBorder,
    chipBlue: AppColors.lightChipBlue,
    chipBlueText: AppColors.lightChipBlueText,
    chipBlueBorder: AppColors.lightChipBlueBorder,
    chipGreen: AppColors.lightChipGreen,
    chipGreenText: AppColors.lightChipGreenText,
    chipGreenBorder: AppColors.lightChipGreenBorder,
    chipGray: AppColors.lightChipGray,
    chipGrayText: AppColors.lightChipGrayText,
    chipGrayBorder: AppColors.lightChipGrayBorder,
    shadow: AppColors.lightShadow,
    shimmerBase: AppColors.lightShimmerBase,
    shimmerHighlight: AppColors.lightShimmerHighlight,
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? surfaceElevated,
    Color? cardBackground,
    Color? cardBackgroundElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? borderLight,
    Color? borderAccent,
    Color? divider,
    Color? navBackground,
    Color? navItemInactive,
    Color? chipOrange,
    Color? chipOrangeText,
    Color? chipOrangeBorder,
    Color? chipBlue,
    Color? chipBlueText,
    Color? chipBlueBorder,
    Color? chipGreen,
    Color? chipGreenText,
    Color? chipGreenBorder,
    Color? chipGray,
    Color? chipGrayText,
    Color? chipGrayBorder,
    Color? shadow,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBackgroundElevated:
          cardBackgroundElevated ?? this.cardBackgroundElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      borderAccent: borderAccent ?? this.borderAccent,
      divider: divider ?? this.divider,
      navBackground: navBackground ?? this.navBackground,
      navItemInactive: navItemInactive ?? this.navItemInactive,
      chipOrange: chipOrange ?? this.chipOrange,
      chipOrangeText: chipOrangeText ?? this.chipOrangeText,
      chipOrangeBorder: chipOrangeBorder ?? this.chipOrangeBorder,
      chipBlue: chipBlue ?? this.chipBlue,
      chipBlueText: chipBlueText ?? this.chipBlueText,
      chipBlueBorder: chipBlueBorder ?? this.chipBlueBorder,
      chipGreen: chipGreen ?? this.chipGreen,
      chipGreenText: chipGreenText ?? this.chipGreenText,
      chipGreenBorder: chipGreenBorder ?? this.chipGreenBorder,
      chipGray: chipGray ?? this.chipGray,
      chipGrayText: chipGrayText ?? this.chipGrayText,
      chipGrayBorder: chipGrayBorder ?? this.chipGrayBorder,
      shadow: shadow ?? this.shadow,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;

    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBackgroundElevated:
          Color.lerp(cardBackgroundElevated, other.cardBackgroundElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderAccent: Color.lerp(borderAccent, other.borderAccent, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navItemInactive: Color.lerp(navItemInactive, other.navItemInactive, t)!,
      chipOrange: Color.lerp(chipOrange, other.chipOrange, t)!,
      chipOrangeText: Color.lerp(chipOrangeText, other.chipOrangeText, t)!,
      chipOrangeBorder:
          Color.lerp(chipOrangeBorder, other.chipOrangeBorder, t)!,
      chipBlue: Color.lerp(chipBlue, other.chipBlue, t)!,
      chipBlueText: Color.lerp(chipBlueText, other.chipBlueText, t)!,
      chipBlueBorder: Color.lerp(chipBlueBorder, other.chipBlueBorder, t)!,
      chipGreen: Color.lerp(chipGreen, other.chipGreen, t)!,
      chipGreenText: Color.lerp(chipGreenText, other.chipGreenText, t)!,
      chipGreenBorder: Color.lerp(chipGreenBorder, other.chipGreenBorder, t)!,
      chipGray: Color.lerp(chipGray, other.chipGray, t)!,
      chipGrayText: Color.lerp(chipGrayText, other.chipGrayText, t)!,
      chipGrayBorder: Color.lerp(chipGrayBorder, other.chipGrayBorder, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}
