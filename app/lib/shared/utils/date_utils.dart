/// Checks if two DateTime objects represent the same calendar day.
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Checks if the given DateTime is today.
bool isToday(DateTime date) {
  final now = DateTime.now();
  return isSameDay(date, now);
}

/// Checks if the given DateTime is tomorrow.
bool isTomorrow(DateTime date) {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  return isSameDay(date, tomorrow);
}

/// Checks if the given DateTime is in the past (before today).
bool isPastDate(DateTime date) {
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  return dateOnly.isBefore(todayOnly);
}

/// Checks if the given DateTime is in the future (after today).
bool isFutureDate(DateTime date) {
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  return dateOnly.isAfter(todayOnly);
}
