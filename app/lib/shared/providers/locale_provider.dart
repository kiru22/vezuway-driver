import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale {
  es,
  ua;

  String get displayName {
    switch (this) {
      case AppLocale.es:
        return 'Español';
      case AppLocale.ua:
        return 'Українська';
    }
  }

  String get code {
    switch (this) {
      case AppLocale.es:
        return 'es';
      case AppLocale.ua:
        return 'uk';
    }
  }
}

final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.es);
