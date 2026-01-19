class AppConfig {
  static const String appName = 'vezuway.';

  // API URL is set at build time via --dart-define=API_URL=...
  // Default to localhost for development
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8001/api/v1',
  );

  // Google Client ID is set at build time via --dart-define=GOOGLE_CLIENT_ID=...
  static const String _googleClientIdEnv = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
  static String? get googleClientId => _googleClientIdEnv.isEmpty ? null : _googleClientIdEnv;

  static const Duration apiTimeout = Duration(seconds: 30);

  static const List<String> supportedLocales = ['es', 'uk', 'en'];
  static const String defaultLocale = 'es';
}
