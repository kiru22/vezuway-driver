import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'shared/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await Hive.initFlutter();

  // Initialize date formatting for both supported locales
  await Future.wait([
    initializeDateFormatting('es_ES', null),
    initializeDateFormatting('uk_UA', null),
  ]);

  // Initialize SharedPreferences for locale persistence
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LogisticsApp(),
    ),
  );
}
