enum GnssCapabilityLevel {
  /// Android API 24+ with full GnssStatus access.
  full,

  /// Android API < 24 — only basic location, no satellite breakdown.
  partialAndroid,

  /// iOS — CLLocationManager only, no satellite-level data.
  iosLocationOnly,

  /// Permission denied by user.
  permissionDenied,

  /// No GNSS hardware on device.
  unavailable;

  bool get canShowSatellites =>
      this == GnssCapabilityLevel.full;

  bool get canShowLocation =>
      this == GnssCapabilityLevel.full ||
      this == GnssCapabilityLevel.partialAndroid ||
      this == GnssCapabilityLevel.iosLocationOnly;

  bool get isIosLimited => this == GnssCapabilityLevel.iosLocationOnly;

  String get limitationMessage {
    switch (this) {
      case GnssCapabilityLevel.full:
        return 'Full GNSS telemetry available.';
      case GnssCapabilityLevel.partialAndroid:
        return 'This device runs Android API < 24. Satellite-level data is unavailable; only basic location is provided.';
      case GnssCapabilityLevel.iosLocationOnly:
        return 'iOS does not expose satellite-level GNSS data via public APIs. Position, speed, heading, and accuracy are available.';
      case GnssCapabilityLevel.permissionDenied:
        return 'Location permission is required to access GNSS data. Grant permission in Settings.';
      case GnssCapabilityLevel.unavailable:
        return 'No GNSS hardware detected on this device.';
    }
  }
}
