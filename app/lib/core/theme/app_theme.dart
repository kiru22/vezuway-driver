import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_colors_extension.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // DESIGN TOKENS
  // ═══════════════════════════════════════════════════════════════════════════

  // Border Radius
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 100.0;

  // Spacing
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 20.0;
  static const double spaceXxl = 24.0;
  static const double spaceXxxl = 32.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME (Primary Theme)
  // ═══════════════════════════════════════════════════════════════════════════

  // Typography - Outfit: Modern geometric sans-serif with warmth
  static String get _fontFamily => GoogleFonts.outfit().fontFamily!;

  static TextTheme get _textTheme => GoogleFonts.outfitTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      ),
    ),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.cardBackground,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.cardBackground,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceLg),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: spaceXxl, vertical: spaceLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: spaceXxl, vertical: spaceLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textMuted,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 8,
        focusElevation: 12,
        hoverElevation: 10,
        highlightElevation: 12,
        shape: const CircleBorder(),
        extendedTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBackground,
        selectedItemColor: AppColors.navItemActive,
        unselectedItemColor: AppColors.navItemInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navBackground,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: 26,
            );
          }
          return const IconThemeData(
            color: AppColors.textMuted,
            size: 24,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surface,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXxl)),
        ),
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipGray,
        deleteIconColor: AppColors.textMuted,
        disabledColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primaryDark,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceXs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: const BorderSide(color: AppColors.chipGrayBorder),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: spaceLg),
        minVerticalPadding: spaceMd,
        iconColor: AppColors.textMuted,
        textColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.textOnPrimary;
          }
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceElevated;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return AppColors.border;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceLight,
        circularTrackColor: AppColors.surfaceLight,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.divider,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: _textTheme,
      extensions: const [AppColorsExtension.dark],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme get _lightTextTheme => GoogleFonts.outfitTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.lightTextPrimary,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        letterSpacing: -1.0,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        letterSpacing: 0.1,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextMuted,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextMuted,
        letterSpacing: 0.5,
      ),
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.primaryDark,
        onSecondary: AppColors.textOnPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightCardBackground,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(
          color: AppColors.lightTextPrimary,
          size: 24,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.lightCardBackground,
        shadowColor: AppColors.lightShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceLg),
        hintStyle: const TextStyle(
          color: AppColors.lightTextMuted,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.lightTextMuted,
        suffixIconColor: AppColors.lightTextMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.lightSurfaceLight,
          disabledForegroundColor: AppColors.lightTextMuted,
          padding: const EdgeInsets.symmetric(horizontal: spaceXxl, vertical: spaceLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          side: const BorderSide(color: AppColors.lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: spaceXxl, vertical: spaceLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        focusElevation: 8,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightNavBackground,
        selectedItemColor: AppColors.navItemActive,
        unselectedItemColor: AppColors.lightNavItemInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.lightSurface,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXxl)),
        ),
        dragHandleColor: AppColors.lightBorder,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.lightTextSecondary,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightChipGray,
        deleteIconColor: AppColors.lightTextMuted,
        disabledColor: AppColors.lightSurfaceLight,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceXs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: const BorderSide(color: AppColors.lightChipGrayBorder),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightSurfaceLight,
        circularTrackColor: AppColors.lightSurfaceLight,
      ),
      textTheme: _lightTextTheme,
      extensions: const [AppColorsExtension.light],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CUSTOM BOX DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: AppColors.border),
      );

  static BoxDecoration get cardDecorationElevated => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: AppColors.glassBorder),
      );

  static BoxDecoration primaryButtonDecoration({bool isPressed = false}) => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: isPressed
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      );
}
