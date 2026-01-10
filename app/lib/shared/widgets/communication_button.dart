import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Botón de comunicación reutilizable para WhatsApp, Viber, Telegram y teléfono.
///
/// Uso:
/// ```dart
/// CommunicationButton.whatsApp(
///   iconColor: colors.success,
///   onTap: () => _openWhatsApp(phone),
/// )
/// ```
class CommunicationButton extends StatelessWidget {
  final Color bgColor;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;
  final CommunicationButtonType type;

  const CommunicationButton({
    super.key,
    required this.bgColor,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
    required this.type,
  });

  /// Constructor para WhatsApp
  factory CommunicationButton.whatsApp({
    Key? key,
    required Color iconColor,
    required VoidCallback onTap,
    Color? bgColor,
    Color? borderColor,
  }) {
    return CommunicationButton(
      key: key,
      bgColor: bgColor ?? Colors.transparent,
      iconColor: iconColor,
      borderColor: borderColor ?? iconColor.withValues(alpha: 0.2),
      onTap: onTap,
      type: CommunicationButtonType.whatsApp,
    );
  }

  /// Constructor para Viber
  factory CommunicationButton.viber({
    Key? key,
    required Color iconColor,
    required VoidCallback onTap,
    Color? bgColor,
    Color? borderColor,
  }) {
    return CommunicationButton(
      key: key,
      bgColor: bgColor ?? Colors.transparent,
      iconColor: iconColor,
      borderColor: borderColor ?? iconColor.withValues(alpha: 0.2),
      onTap: onTap,
      type: CommunicationButtonType.viber,
    );
  }

  /// Constructor para Telegram
  factory CommunicationButton.telegram({
    Key? key,
    required Color iconColor,
    required VoidCallback onTap,
    Color? bgColor,
    Color? borderColor,
  }) {
    return CommunicationButton(
      key: key,
      bgColor: bgColor ?? Colors.transparent,
      iconColor: iconColor,
      borderColor: borderColor ?? iconColor.withValues(alpha: 0.2),
      onTap: onTap,
      type: CommunicationButtonType.telegram,
    );
  }

  /// Constructor para teléfono
  factory CommunicationButton.phone({
    Key? key,
    required Color iconColor,
    required VoidCallback onTap,
    Color? bgColor,
    Color? borderColor,
  }) {
    return CommunicationButton(
      key: key,
      bgColor: bgColor ?? Colors.transparent,
      iconColor: iconColor,
      borderColor: borderColor ?? iconColor.withValues(alpha: 0.2),
      onTap: onTap,
      type: CommunicationButtonType.phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final assetPath = switch (type) {
      CommunicationButtonType.whatsApp => 'assets/icons/whatsapp.svg',
      CommunicationButtonType.viber => 'assets/icons/viber.svg',
      CommunicationButtonType.telegram => 'assets/icons/telegram.svg',
      CommunicationButtonType.phone => 'assets/icons/phone.svg',
    };

    return SvgPicture.asset(
      assetPath,
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}

enum CommunicationButtonType {
  whatsApp,
  viber,
  telegram,
  phone,
}
