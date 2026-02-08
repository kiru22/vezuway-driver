import 'package:url_launcher/url_launcher.dart';

class ContactLauncher {
  ContactLauncher._();

  static String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static Future<bool> openWhatsApp(String phone, {String? message}) async {
    final cleanPhone = _cleanPhone(phone);
    var url = 'https://wa.me/$cleanPhone';
    if (message != null && message.isNotEmpty) {
      url += '?text=${Uri.encodeComponent(message)}';
    }
    final uri = Uri.parse(url);
    return _launchUrl(uri);
  }

  static Future<bool> openTelegram(String phone) async {
    final cleanPhone = _cleanPhone(phone);
    final uri = Uri.parse('https://t.me/$cleanPhone');
    return _launchUrl(uri);
  }

  static Future<bool> openViber(String phone) async {
    final cleanPhone = _cleanPhone(phone);
    final uri = Uri.parse('viber://chat?number=$cleanPhone');
    return _launchUrl(uri);
  }

  static Future<bool> makePhoneCall(String phone) async {
    final cleanPhone = _cleanPhone(phone);
    final uri = Uri.parse('tel:$cleanPhone');
    return _launchUrl(uri);
  }

  static Future<bool> openMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    return _launchUrl(uri);
  }

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
