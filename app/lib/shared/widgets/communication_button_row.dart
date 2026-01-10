import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../utils/contact_launcher.dart';
import 'communication_button.dart';

/// Fila de 4 botones de comunicación: Teléfono, Viber, WhatsApp, Telegram.
///
/// Uso:
/// ```dart
/// CommunicationButtonRow(phone: package.receiverPhone!)
/// ```
class CommunicationButtonRow extends StatelessWidget {
  final String phone;
  final EdgeInsets padding;

  const CommunicationButtonRow({
    super.key,
    required this.phone,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: CommunicationButton(
              bgColor: AppColors.phoneBg,
              iconColor: AppColors.phoneText,
              borderColor: AppColors.phoneBorder,
              type: CommunicationButtonType.phone,
              onTap: () => ContactLauncher.makePhoneCall(phone),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CommunicationButton(
              bgColor: AppColors.viberBg,
              iconColor: AppColors.viberText,
              borderColor: AppColors.viberBorder,
              type: CommunicationButtonType.viber,
              onTap: () => ContactLauncher.openViber(phone),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CommunicationButton(
              bgColor: AppColors.whatsappBg,
              iconColor: AppColors.whatsappText,
              borderColor: AppColors.whatsappBorder,
              type: CommunicationButtonType.whatsApp,
              onTap: () => ContactLauncher.openWhatsApp(phone),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CommunicationButton(
              bgColor: AppColors.telegramBg,
              iconColor: AppColors.telegramText,
              borderColor: AppColors.telegramBorder,
              type: CommunicationButtonType.telegram,
              onTap: () => ContactLauncher.openTelegram(phone),
            ),
          ),
        ],
      ),
    );
  }
}
