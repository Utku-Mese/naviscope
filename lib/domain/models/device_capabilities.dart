import '../enums/gnss_capability_level.dart';

class DeviceCapabilities {
  final bool isAndroid;
  final bool isIOS;
  final String platformVersion;
  final GnssCapabilityLevel gnssLevel;
  final bool hasGnssStatus;
  final bool hasGnssMeasurements;
  final bool hasCarrierFrequency;
  final bool hasVerticalAccuracy;
  final bool hasSpeed;
  final bool hasHeading;
  final String? deviceModel;
  // On Android: false when only ACCESS_COARSE_LOCATION is granted.
  // GnssStatus.Callback requires fine permission — without it satellite
  // data will never arrive even though location updates work normally.
  final bool hasFineLocationPermission;

  const DeviceCapabilities({
    required this.isAndroid,
    required this.isIOS,
    required this.platformVersion,
    required this.gnssLevel,
    required this.hasGnssStatus,
    required this.hasGnssMeasurements,
    required this.hasCarrierFrequency,
    required this.hasVerticalAccuracy,
    required this.hasSpeed,
    required this.hasHeading,
    this.deviceModel,
    this.hasFineLocationPermission = true,
  });

  /// Reasonable defaults used while detection is loading.
  factory DeviceCapabilities.unknown() {
    return const DeviceCapabilities(
      isAndroid: false,
      isIOS: false,
      platformVersion: 'Unknown',
      gnssLevel: GnssCapabilityLevel.unavailable,
      hasGnssStatus: false,
      hasGnssMeasurements: false,
      hasCarrierFrequency: false,
      hasVerticalAccuracy: false,
      hasSpeed: false,
      hasHeading: false,
    );
  }

  factory DeviceCapabilities.fromMap(Map<String, dynamic> map) {
    final level = _levelFromString(map['gnssLevel'] as String? ?? 'unavailable');
    return DeviceCapabilities(
      isAndroid: map['isAndroid'] as bool? ?? false,
      isIOS: map['isIOS'] as bool? ?? false,
      platformVersion: map['platformVersion'] as String? ?? 'Unknown',
      gnssLevel: level,
      hasGnssStatus: map['hasGnssStatus'] as bool? ?? false,
      hasGnssMeasurements: map['hasGnssMeasurements'] as bool? ?? false,
      hasCarrierFrequency: map['hasCarrierFrequency'] as bool? ?? false,
      hasVerticalAccuracy: map['hasVerticalAccuracy'] as bool? ?? false,
      hasSpeed: map['hasSpeed'] as bool? ?? false,
      hasHeading: map['hasHeading'] as bool? ?? false,
      deviceModel: map['deviceModel'] as String?,
      hasFineLocationPermission:
          map['hasFineLocationPermission'] as bool? ?? true,
    );
  }

  static GnssCapabilityLevel _levelFromString(String s) {
    switch (s) {
      case 'full':
        return GnssCapabilityLevel.full;
      case 'partialAndroid':
        return GnssCapabilityLevel.partialAndroid;
      case 'iosLocationOnly':
        return GnssCapabilityLevel.iosLocationOnly;
      case 'permissionDenied':
        return GnssCapabilityLevel.permissionDenied;
      default:
        return GnssCapabilityLevel.unavailable;
    }
  }
}
