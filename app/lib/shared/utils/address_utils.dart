/// Utilidades para manejo de direcciones
class AddressUtils {
  AddressUtils._();

  /// Combina dirección y ciudad en una cadena completa.
  /// Usado para mostrar direcciones en pantalla de detalle.
  static String? buildFullAddress(String? address, String? city) {
    if (address == null && city == null) return null;
    if (address == null) return city;
    if (city == null) return address;
    return '$address, $city';
  }

  /// Construye dirección a partir de partes: nombre ciudad, dirección exacta y enlace Maps.
  /// Usado para crear nuevos paquetes.
  static String buildAddressFromParts({
    String? cityName,
    String exactAddress = '',
    String? googleMapsLink,
  }) {
    final parts = <String>[];

    if (cityName != null && cityName.isNotEmpty) {
      parts.add(cityName);
    }

    if (exactAddress.isNotEmpty) {
      parts.add(exactAddress);
    }

    if (googleMapsLink != null && googleMapsLink.isNotEmpty) {
      parts.add('Maps: $googleMapsLink');
    }

    return parts.join(', ');
  }

  /// Extrae la ciudad de una dirección completa.
  /// Asume que la ciudad es el último segmento separado por coma.
  static String extractCity(String? address) {
    if (address == null || address.isEmpty) return '-';
    final parts = address.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    return address;
  }
}
