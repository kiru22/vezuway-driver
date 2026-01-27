enum DriverStatus {
  pending,
  approved,
  rejected;

  String get value => name;

  static DriverStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in values) {
      if (status.name == value) return status;
    }
    return null;
  }
}
