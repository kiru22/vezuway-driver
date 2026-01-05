class AppConfig {
  static const String appName = 'Logistics UA-ES';

  // API URL is set at build time via --dart-define=API_URL=...
  // Default to localhost for development
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const Duration apiTimeout = Duration(seconds: 30);

  static const List<String> supportedLocales = ['es', 'uk', 'en'];
  static const String defaultLocale = 'es';
}
