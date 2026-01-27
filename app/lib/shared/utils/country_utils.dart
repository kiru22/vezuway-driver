/// Returns the flag emoji for a given country code.
///
/// Supports: UA (Ukraine), ES (Spain), PL (Poland), DE (Germany).
/// Returns a white flag for unknown country codes.
String getCountryFlag(String countryCode) {
  switch (countryCode.toUpperCase()) {
    case 'UA':
      return '\u{1F1FA}\u{1F1E6}'; // Ukraine flag
    case 'ES':
      return '\u{1F1EA}\u{1F1F8}'; // Spain flag
    case 'PL':
      return '\u{1F1F5}\u{1F1F1}'; // Poland flag
    case 'DE':
      return '\u{1F1E9}\u{1F1EA}'; // Germany flag
    default:
      return '\u{1F3F3}\u{FE0F}'; // White flag
  }
}
