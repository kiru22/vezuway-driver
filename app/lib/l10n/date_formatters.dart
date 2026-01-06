import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../shared/providers/locale_provider.dart';

/// Provides locale-aware date formatters.
///
/// Usage with Riverpod:
/// ```dart
/// final formatters = ref.watch(dateFormattersProvider);
/// Text(formatters.shortDate.format(date))
/// ```
class LocalizedDateFormatters {
  final String localeCode;

  LocalizedDateFormatters(this.localeCode);

  /// Full date with weekday: "lunes, 5 enero" / "понедiлок, 5 сiчня"
  DateFormat get fullDate => DateFormat('EEEE, d MMMM', localeCode);

  /// Short date with year: "5 ene 2026"
  DateFormat get shortDate => DateFormat('d MMM yyyy', localeCode);

  /// Short date without year: "5 ene"
  DateFormat get shortDateNoYear => DateFormat('d MMM', localeCode);

  /// Full date and time: "05/01/2026 14:30"
  DateFormat get dateTime => DateFormat('dd/MM/yyyy HH:mm', localeCode);

  /// Time only: "14:30"
  DateFormat get time => DateFormat('HH:mm', localeCode);

  /// Month and year: "enero 2026"
  DateFormat get monthYear => DateFormat('MMMM yyyy', localeCode);

  /// Day of month: "5"
  DateFormat get dayOfMonth => DateFormat('d', localeCode);

  /// Abbreviated weekday: "lun"
  DateFormat get weekdayShort => DateFormat('E', localeCode);
}

/// Provider for localized date formatters.
/// Automatically updates when the app locale changes.
final dateFormattersProvider = Provider<LocalizedDateFormatters>((ref) {
  final locale = ref.watch(localeProvider);
  final code = locale == AppLocale.uk ? 'uk_UA' : 'es_ES';
  return LocalizedDateFormatters(code);
});
