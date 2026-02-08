import '../utils/country_utils.dart';

class CityModel {
  final String name;
  final String nameEs;
  final String nameUk;
  final String country;
  final String? region;

  const CityModel({
    required this.name,
    String? nameEs,
    String? nameUk,
    required this.country,
    this.region,
  })  : nameEs = nameEs ?? name,
        nameUk = nameUk ?? name;

  String get displayName => name;

  String getLocalizedName(String locale) {
    if (locale.startsWith('uk')) return nameUk;
    if (locale.startsWith('es')) return nameEs;
    return name;
  }

  String getLocalizedCountry(String locale) {
    if (locale.startsWith('uk')) {
      switch (country) {
        case 'ES':
          return 'Iспанiя';
        case 'UA':
          return 'Україна';
        case 'PL':
          return 'Польща';
        case 'DE':
          return 'Німеччина';
        default:
          return country;
      }
    }
    switch (country) {
      case 'ES':
        return 'Espana';
      case 'UA':
        return 'Ucrania';
      case 'PL':
        return 'Polonia';
      case 'DE':
        return 'Alemania';
      default:
        return country;
    }
  }

  String get countryName {
    switch (country) {
      case 'ES':
        return 'Espana';
      case 'UA':
        return 'Ucrania';
      case 'PL':
        return 'Polonia';
      case 'DE':
        return 'Alemania';
      default:
        return country;
    }
  }

  String get countryFlag => getCountryFlag(country);

  String get fullDisplayName => '$name, $countryName';

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['city'] as String,
      country: json['country'] as String,
    );
  }

  factory CityModel.fromApiJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      nameEs: json['name_es'] as String?,
      nameUk: json['name_uk'] as String?,
      country: json['country_code'] as String,
      region: json['admin1_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'city': name,
        'country': country,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CityModel && other.name == name && other.country == country;
  }

  @override
  int get hashCode => name.hashCode ^ country.hashCode;

  @override
  String toString() => 'CityModel($name, $country)';
}
