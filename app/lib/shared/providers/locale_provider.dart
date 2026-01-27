import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/providers/auth_provider.dart';

enum AppLocale {
  es,
  uk;

  String get displayName {
    switch (this) {
      case AppLocale.es:
        return 'Espanol';
      case AppLocale.uk:
        return 'Українська';
    }
  }

  String get code {
    switch (this) {
      case AppLocale.es:
        return 'es';
      case AppLocale.uk:
        return 'uk';
    }
  }

  String get buttonText {
    switch (this) {
      case AppLocale.es:
        return 'ES';
      case AppLocale.uk:
        return 'UA';
    }
  }

  Locale get locale => Locale(code);

  static AppLocale fromCode(String code) {
    switch (code) {
      case 'uk':
        return AppLocale.uk;
      case 'es':
      default:
        return AppLocale.es;
    }
  }

  static AppLocale fromLocale(Locale locale) {
    return fromCode(locale.languageCode);
  }
}

class LocaleNotifier extends StateNotifier<AppLocale> {
  static const _key = 'app_locale';
  final SharedPreferences _prefs;
  final Ref _ref;
  bool _isUpdating = false;

  LocaleNotifier(this._prefs, this._ref) : super(_loadInitial(_prefs));

  static AppLocale _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    if (saved == 'uk') return AppLocale.uk;
    return AppLocale.es;
  }

  void initFromUser(String localeCode) {
    final locale = AppLocale.fromCode(localeCode);
    state = locale;
    _prefs.setString(_key, locale.code);
  }

  Future<void> setLocale(AppLocale locale) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final oldState = state;
    state = locale;
    await _prefs.setString(_key, locale.code);

    try {
      final authState = _ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated &&
          authState.user != null) {
        final repository = _ref.read(authRepositoryProvider);
        await repository.updateProfile(locale: locale.code);
      }
    } catch (e) {
      state = oldState;
      await _prefs.setString(_key, oldState.code);
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> toggle() async {
    final newLocale = state == AppLocale.es ? AppLocale.uk : AppLocale.es;
    await setLocale(newLocale);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notifier = LocaleNotifier(prefs, ref);

  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.status == AuthStatus.authenticated && next.user != null) {
      notifier.initFromUser(next.user!.locale);
    }
  });

  return notifier;
});
