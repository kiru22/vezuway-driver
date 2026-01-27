import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/providers/auth_provider.dart';
import 'locale_provider.dart';

ThemeMode _stringToThemeMode(String preference) {
  switch (preference) {
    case 'light':
      return ThemeMode.light;
    case 'system':
      return ThemeMode.system;
    case 'dark':
    default:
      return ThemeMode.dark;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.system:
      return 'system';
    case ThemeMode.dark:
      return 'dark';
  }
}

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'app_theme';
  final SharedPreferences _prefs;
  final Ref _ref;
  bool _isUpdating = false;

  ThemeNotifier(this._prefs, this._ref) : super(_loadInitial(_prefs));

  static ThemeMode _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    if (saved != null) return _stringToThemeMode(saved);
    return ThemeMode.dark;
  }

  void initFromUser(String themePreference) {
    final mode = _stringToThemeMode(themePreference);
    state = mode;
    _prefs.setString(_key, _themeModeToString(mode));
  }

  void reset() {
    state = ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final oldState = state;
    state = mode;
    await _prefs.setString(_key, _themeModeToString(mode));

    try {
      final authState = _ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated &&
          authState.user != null) {
        final repository = _ref.read(authRepositoryProvider);
        await repository.updateProfile(
          themePreference: _themeModeToString(mode),
        );
      }
    } catch (e) {
      state = oldState;
      await _prefs.setString(_key, _themeModeToString(oldState));
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notifier = ThemeNotifier(prefs, ref);

  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.status == AuthStatus.authenticated && next.user != null) {
      notifier.initFromUser(next.user!.themePreference);
    } else if (next.status == AuthStatus.unauthenticated) {
      notifier.reset();
    }
  });

  return notifier;
});

final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeModeProvider) == ThemeMode.dark;
});
