import 'package:url_launcher/url_launcher.dart';

/// Helper para abrir aplicaciones de comunicación con números de teléfono.
class ContactLauncher {
  ContactLauncher._();

  /// Limpia el número de teléfono, dejando solo dígitos y el signo +
  static String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Abre WhatsApp con el número de teléfono especificado.
  /// Usa la URL web de WhatsApp que funciona en todas las plataformas.
  static Future<bool> openWhatsApp(String phone) async {
    final cleanPhone = _cleanPhone(phone);
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    return _launchUrl(uri);
  }

  /// Abre Telegram con el número de teléfono especificado.
  /// Usa la URL web de Telegram que funciona en todas las plataformas.
  static Future<bool> openTelegram(String phone) async {
    final cleanPhone = _cleanPhone(phone);
    final uri = Uri.parse('https://t.me/$cleanPhone');
    return _launchUrl(uri);
  }

  /// Abre Viber con el número de teléfono especificado.
  /// Usa el protocolo viber:// para abrir la app directamente.
  static Future<bool> openViber(String phone) async {
    final cleanPhone = _cleanPhone(phone);
    final uri = Uri.parse('viber://chat?number=$cleanPhone');
    return _launchUrl(uri);
  }

  /// Inicia una llamada telefónica al número especificado.
  static Future<bool> makePhoneCall(String phone) async {
    final cleanPhone = _cleanPhone(phone);
    final uri = Uri.parse('tel:$cleanPhone');
    return _launchUrl(uri);
  }

  /// Abre Google Maps con la dirección especificada.
  static Future<bool> openMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    return _launchUrl(uri);
  }

  /// Lanza una URL, manejando errores silenciosamente.
  static Future<bool> _launchUrl(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
