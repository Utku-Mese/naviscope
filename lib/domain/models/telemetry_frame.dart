import 'location_sample.dart';
import 'gnss_snapshot.dart';

class TelemetryFrame {
  final LocationSample location;
  final GnssSnapshot? gnss;
  final DateTime receivedAt;

  const TelemetryFrame({
    required this.location,
    this.gnss,
    required this.receivedAt,
  });

  factory TelemetryFrame.fromMap(Map<String, dynamic> map) {
    final locationMap =
        Map<String, dynamic>.from(map['location'] as Map);
    GnssSnapshot? gnss;
    if (map['gnss'] != null) {
      try {
        gnss = GnssSnapshot.fromMap(
          Map<String, dynamic>.from(map['gnss'] as Map),
        );
      } catch (_) {
        // Bad satellite payload must not kill the whole telemetry stream.
        gnss = null;
      }
    }

    return TelemetryFrame(
      location: LocationSample.fromMap(locationMap),
      gnss: gnss,
      receivedAt: DateTime.now(),
    );
  }
}
