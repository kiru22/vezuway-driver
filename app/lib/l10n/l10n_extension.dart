import 'package:flutter/widgets.dart';
import '../generated/l10n/app_localizations.dart';

/// Extension to easily access localized strings via context.
///
/// Usage:
/// ```dart
/// Text(context.l10n.auth_loginButton)
/// ```
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
