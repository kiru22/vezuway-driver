import 'package:flutter/material.dart';

/// Paleta de colores premium oscura con acentos naranjas
/// Inspirada en diseño de apps de delivery de alta gama
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY - Naranja Vibrante
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color primaryDark = Color(0xFFE55B25);
  static const Color primaryMuted = Color(0xFFFF6B35);

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUNDS - Escala de Grises Oscuros
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color cardBackgroundElevated = Color(0xFF252525);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF737373);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE5E5E5);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // ═══════════════════════════════════════════════════════════════════════════
  // CHIP BACKGROUNDS - Estilo oscuro con borde sutil
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color chipOrange = Color(0xFF2D1F17);
  static const Color chipOrangeText = Color(0xFFFF8A5C);
  static const Color chipOrangeBorder = Color(0xFF4D3326);

  static const Color chipBlue = Color(0xFF172033);
  static const Color chipBlueText = Color(0xFF60A5FA);
  static const Color chipBlueBorder = Color(0xFF1E3A5F);

  static const Color chipGreen = Color(0xFF14261A);
  static const Color chipGreenText = Color(0xFF4ADE80);
  static const Color chipGreenBorder = Color(0xFF1A3D26);

  static const Color chipGray = Color(0xFF262626);
  static const Color chipGrayText = Color(0xFF9CA3AF);
  static const Color chipGrayBorder = Color(0xFF3D3D3D);

  static const Color chipPurple = Color(0xFF1F172D);
  static const Color chipPurpleText = Color(0xFFA78BFA);
  static const Color chipPurpleBorder = Color(0xFF2E2247);

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF333333);
  static const Color borderAccent = Color(0xFF3D2A20);
  static const Color divider = Color(0xFF262626);
  static const Color dividerLight = Color(0xFF303030);

  // ═══════════════════════════════════════════════════════════════════════════
  // CAPACITY BAR
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color capacityBackground = Color(0xFF262626);
  static const Color capacityFill = Color(0xFFFBBF24);
  static const Color capacityFillLow = Color(0xFF22C55E);
  static const Color capacityFillHigh = Color(0xFFEF4444);

  // ═══════════════════════════════════════════════════════════════════════════
  // RATING & ACCENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color ratingStar = Color(0xFFFBBF24);
  static const Color ratingStarEmpty = Color(0xFF404040);
  static const Color verified = Color(0xFF22C55E);

  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOWS & OVERLAYS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color shadow = Color(0xFF000000);
  static const Color shadowLight = Color(0x40000000);
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Glassmorphism
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A5C), Color(0xFFFF6B35), Color(0xFFE55B25)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E1E), Color(0xFF1A1A1A)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF141414), Color(0xFF0A0A0A)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color glowOrange = Color(0x40FF6B35);
  static const Color glowSuccess = Color(0x4022C55E);
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = Color(0xFF2A2A2A);

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color navBackground = Color(0xFF141414);
  static const Color navItemActive = Color(0xFFFF6B35);
  static const Color navItemInactive = Color(0xFF666666);
  static const Color navIndicator = Color(0xFFFF6B35);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Light Backgrounds
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF3F4F6);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  // Light Text
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Light Borders
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderLight = Color(0xFFF1F5F9);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Light Chips
  static const Color lightChipOrange = Color(0xFFFFF7ED);
  static const Color lightChipOrangeText = Color(0xFFEA580C);
  static const Color lightChipOrangeBorder = Color(0xFFFED7AA);

  static const Color lightChipBlue = Color(0xFFEFF6FF);
  static const Color lightChipBlueText = Color(0xFF2563EB);
  static const Color lightChipBlueBorder = Color(0xFFBFDBFE);

  static const Color lightChipGreen = Color(0xFFF0FDF4);
  static const Color lightChipGreenText = Color(0xFF16A34A);
  static const Color lightChipGreenBorder = Color(0xFFBBF7D0);

  static const Color lightChipGray = Color(0xFFF9FAFB);
  static const Color lightChipGrayText = Color(0xFF6B7280);
  static const Color lightChipGrayBorder = Color(0xFFE5E7EB);

  // Light Navigation
  static const Color lightNavBackground = Color(0xFFFFFFFF);
  static const Color lightNavItemInactive = Color(0xFF94A3B8);

  // Light Shadows
  static const Color lightShadow = Color(0x1A000000);

  // Light Shimmer
  static const Color lightShimmerBase = Color(0xFFF3F4F6);
  static const Color lightShimmerHighlight = Color(0xFFFFFFFF);
}
