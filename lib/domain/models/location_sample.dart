import '../enums/gnss_fix_type.dart';

class LocationSample {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final double? horizontalAccuracy;
  final double? verticalAccuracy;
  final DateTime timestamp;
  final LocationSource source;

  const LocationSample({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.horizontalAccuracy,
    this.verticalAccuracy,
    required this.timestamp,
    this.source = LocationSource.gnss,
  });

  LocationSample copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? heading,
    double? horizontalAccuracy,
    double? verticalAccuracy,
    DateTime? timestamp,
    LocationSource? source,
  }) {
    return LocationSample(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      horizontalAccuracy: horizontalAccuracy ?? this.horizontalAccuracy,
      verticalAccuracy: verticalAccuracy ?? this.verticalAccuracy,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }

  factory LocationSample.fromMap(Map<String, dynamic> map) {
    return LocationSample(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      altitude: map['altitude'] != null
          ? (map['altitude'] as num).toDouble()
          : null,
      speed: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      heading:
          map['heading'] != null ? (map['heading'] as num).toDouble() : null,
      horizontalAccuracy: map['horizontalAccuracy'] != null
          ? (map['horizontalAccuracy'] as num).toDouble()
          : null,
      verticalAccuracy: map['verticalAccuracy'] != null
          ? (map['verticalAccuracy'] as num).toDouble()
          : null,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['timestamp'] as num).toInt(),
              isUtc: true,
            )
          : DateTime.now().toUtc(),
      source: _sourceFromString(map['source'] as String? ?? 'unknown'),
    );
  }

  static LocationSource _sourceFromString(String s) {
    switch (s) {
      case 'gps':
        return LocationSource.gnss;
      case 'network':
        return LocationSource.network;
      case 'fused':
        return LocationSource.fused;
      default:
        return LocationSource.unknown;
    }
  }

  /// Speed in km/h
  double? get speedKmh => speed != null ? speed! * 3.6 : null;

  /// Speed in knots
  double? get speedKnots => speed != null ? speed! * 1.94384 : null;
}
