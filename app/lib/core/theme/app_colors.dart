import 'package:flutter/material.dart';

/// Paleta de colores premium con acentos Emerald/Teal
/// Design System v1.3 - Clean Modern
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY - Emerald/Teal Gradient
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF10B981);      // emerald-500
  static const Color primaryLight = Color(0xFF34D399); // emerald-400
  static const Color primaryDark = Color(0xFF0D9488);  // teal-600
  static const Color primaryMuted = Color(0xFF10B981);

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUNDS - Titanium Dark (Design System v1.3)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color background = Color(0xFF111827);       // Titanium - slate-900
  static const Color surface = Color(0xFF1F2937);          // slate-800
  static const Color surfaceLight = Color(0xFF374151);     // slate-700
  static const Color surfaceElevated = Color(0xFF1F2937);  // slate-800
  static const Color cardBackground = Color(0xFF1F2937);   // slate-800
  static const Color cardBackgroundElevated = Color(0xFF374151); // slate-700

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textMuted = Color(0xFF737373);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE5E5E5);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS (base)
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
  // STATUS BADGES (Design System v1.3 - Feedback & Estados)
  // ═══════════════════════════════════════════════════════════════════════════
  // Info - "En Camino" (blue)
  static const Color statusInfoBg = Color(0xFFDBEAFE);      // blue-100
  static const Color statusInfoText = Color(0xFF1D4ED8);    // blue-700

  // Success - "Completado" (green)
  static const Color statusSuccessBg = Color(0xFFDCFCE7);   // green-100
  static const Color statusSuccessText = Color(0xFF15803D); // green-700

  // Warning (orange)
  static const Color statusWarningBg = Color(0xFFFFEDD5);   // orange-100
  static const Color statusWarningText = Color(0xFFC2410C); // orange-700

  // Error (red)
  static const Color statusErrorBg = Color(0xFFFEE2E2);     // red-100
  static const Color statusErrorText = Color(0xFFB91C1C);   // red-700

  // Neutral (slate)
  static const Color statusNeutralBg = Color(0xFFF1F5F9);   // slate-100
  static const Color statusNeutralText = Color(0xFF475569); // slate-600

  // ═══════════════════════════════════════════════════════════════════════════
  // CHIP BACKGROUNDS - Estilo oscuro con borde sutil
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color chipOrange = Color(0xFF2D1F17);
  static const Color chipOrangeText = Color(0xFFFF8A5C);
  static const Color chipOrangeBorder = Color(0xFF4D3326);

  static const Color chipBlue = Color(0xFF14261A);        // emerald dark bg
  static const Color chipBlueText = Color(0xFF34D399);    // emerald-400
  static const Color chipBlueBorder = Color(0xFF1A3D26);  // emerald dark border

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
  // COMMUNICATION BUTTONS (WhatsApp, Telegram, Viber)
  // ═══════════════════════════════════════════════════════════════════════════
  // WhatsApp - green
  static const Color whatsappBg = Color(0xFFDCFCE7);       // green-100
  static const Color whatsappText = Color(0xFF16A34A);     // green-600
  static const Color whatsappBorder = Color(0xFFBBF7D0);   // green-200

  // Viber - purple
  static const Color viberBg = Color(0xFFF3E8FF);          // purple-100
  static const Color viberText = Color(0xFF9333EA);        // purple-600
  static const Color viberBorder = Color(0xFFE9D5FF);      // purple-200

  // Telegram - blue
  static const Color telegramBg = Color(0xFFDBEAFE);       // blue-100
  static const Color telegramText = Color(0xFF2563EB);     // blue-600
  static const Color telegramBorder = Color(0xFFBFDBFE);   // blue-200

  // Phone call - gray
  static const Color phoneBg = Color(0xFFF3F4F6);          // gray-100
  static const Color phoneText = Color(0xFF4B5563);        // gray-600
  static const Color phoneBorder = Color(0xFFE5E7EB);      // gray-200

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color border = Color(0xFF374151);       // slate-700
  static const Color borderLight = Color(0xFF4B5563);  // slate-600
  static const Color borderAccent = Color(0xFF10B981); // emerald-500
  static const Color divider = Color(0xFF374151);      // slate-700
  static const Color dividerLight = Color(0xFF4B5563); // slate-600

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
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF10B981), Color(0xFF0D9488)], // emerald-500 → teal-600
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F2937), Color(0xFF111827)], // slate-800 → Titanium
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1F2937), Color(0xFF111827)], // slate-800 → Titanium
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color glowPrimary = Color(0x4010B981);  // emerald glow
  static const Color glowSuccess = Color(0x4022C55E);
  static const Color shimmerBase = Color(0xFF1F2937);     // slate-800
  static const Color shimmerHighlight = Color(0xFF374151); // slate-700

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color navBackground = Color(0xFF111827);   // Titanium
  static const Color navItemActive = Color(0xFF10B981);   // emerald-500
  static const Color navItemInactive = Color(0xFF6B7280); // gray-500
  static const Color navIndicator = Color(0xFF10B981);    // emerald-500

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Light Backgrounds (Design System v1.3)
  static const Color lightBackground = Color(0xFFF0F1F3);  // bgMain
  static const Color lightSurface = Color(0xFFFFFFFF);     // bgCard
  static const Color lightSurfaceLight = Color(0xFFF1F5F9); // neutral bg
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  // Light Text (Design System v1.3)
  static const Color lightTextPrimary = Color(0xFF1E293B);   // slate-800
  static const Color lightTextSecondary = Color(0xFF64748B); // slate-500
  static const Color lightTextMuted = Color(0xFF94A3B8);     // slate-400

  // Light Borders
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderLight = Color(0xFFF1F5F9);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Light Chips
  static const Color lightChipOrange = Color(0xFFFFF7ED);
  static const Color lightChipOrangeText = Color(0xFFEA580C);
  static const Color lightChipOrangeBorder = Color(0xFFFED7AA);

  static const Color lightChipBlue = Color(0xFFD1FAE5);     // emerald-100
  static const Color lightChipBlueText = Color(0xFF10B981);  // emerald-500
  static const Color lightChipBlueBorder = Color(0xFFA7F3D0); // emerald-200

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
