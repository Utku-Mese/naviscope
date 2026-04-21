import 'dart:async';
import 'dart:math' as math;

import '../../domain/enums/gnss_capability_level.dart';
import '../../domain/enums/gnss_constellation.dart';
import '../../domain/enums/gnss_fix_type.dart';
import '../../domain/models/device_capabilities.dart';
import '../../domain/models/gnss_snapshot.dart';
import '../../domain/models/location_sample.dart';
import '../../domain/models/satellite_info.dart';
import '../../domain/models/telemetry_frame.dart';
import '../../domain/repositories/telemetry_repository.dart';

class MockGnssProvider implements TelemetryRepository {
  final _controller = StreamController<TelemetryFrame>.broadcast();
  Timer? _timer;
  final _random = math.Random(42);

  // Simulated walk — slow drift so the position changes visibly
  double _lat = 48.8584;
  double _lon = 2.2945;
  double _alt = 35.0;
  double _heading = 45.0;
  double _speed = 1.2;
  int _tick = 0;

  static const _mockSatellites = [
    (1, GnssConstellation.gps, 42.0, 215.0, 68.0),
    (7, GnssConstellation.gps, 38.5, 110.0, 42.0),
    (11, GnssConstellation.gps, 35.0, 330.0, 25.0),
    (17, GnssConstellation.gps, 40.2, 75.0, 55.0),
    (28, GnssConstellation.gps, 22.0, 190.0, 15.0),
    (3, GnssConstellation.glonass, 33.0, 290.0, 38.0),
    (9, GnssConstellation.glonass, 28.5, 45.0, 30.0),
    (14, GnssConstellation.glonass, 18.0, 160.0, 12.0),
    (1, GnssConstellation.galileo, 39.0, 240.0, 60.0),
    (4, GnssConstellation.galileo, 31.5, 130.0, 35.0),
    (7, GnssConstellation.galileo, 26.0, 350.0, 20.0),
    (12, GnssConstellation.beidou, 36.0, 85.0, 48.0),
    (19, GnssConstellation.beidou, 29.0, 200.0, 32.0),
    (25, GnssConstellation.beidou, 15.0, 310.0, 8.0),
    (193, GnssConstellation.qzss, 44.0, 150.0, 72.0),
    (131, GnssConstellation.sbas, 37.0, 185.0, 30.0),
  ];

  @override
  Stream<TelemetryFrame> get telemetryStream => _controller.stream;

  @override
  Future<DeviceCapabilities> getCapabilities() async {
    return const DeviceCapabilities(
      isAndroid: true,
      isIOS: false,
      platformVersion: 'Mock Android 14',
      gnssLevel: GnssCapabilityLevel.full,
      hasGnssStatus: true,
      hasGnssMeasurements: true,
      hasCarrierFrequency: true,
      hasVerticalAccuracy: true,
      hasSpeed: true,
      hasHeading: true,
      deviceModel: 'Mock Pixel 8 Pro',
    );
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> startListening() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _tick++;
      _emitFrame();
    });
  }

  @override
  Future<void> stopListening() async {
    _timer?.cancel();
    _timer = null;
  }

  void _emitFrame() {
    // Drift position slowly
    _lat += (_random.nextDouble() - 0.5) * 0.00002;
    _lon += (_random.nextDouble() - 0.5) * 0.00002;
    _alt += (_random.nextDouble() - 0.5) * 0.3;
    _heading = (_heading + _random.nextDouble() * 2 - 1) % 360;
    _speed = (_speed + _random.nextDouble() * 0.1 - 0.05).clamp(0.5, 5.0);

    final location = LocationSample(
      latitude: _lat,
      longitude: _lon,
      altitude: _alt,
      speed: _speed,
      heading: _heading,
      horizontalAccuracy: 2.5 + _random.nextDouble() * 0.5,
      verticalAccuracy: 4.0 + _random.nextDouble() * 1.0,
      timestamp: DateTime.now().toUtc(),
      source: LocationSource.gnss,
    );

    final satellites = _buildSatellites();
    final used = satellites.where((s) => s.usedInFix).length;

    final gnss = GnssSnapshot(
      satellites: satellites,
      satellitesVisible: satellites.length,
      satellitesUsedInFix: used,
      fixType: used >= 4 ? GnssFixType.fix3D : GnssFixType.fix2D,
      timestamp: DateTime.now().toUtc(),
    );

    _controller.add(TelemetryFrame(
      location: location,
      gnss: gnss,
      receivedAt: DateTime.now(),
    ));
  }

  List<SatelliteInfo> _buildSatellites() {
    return _mockSatellites.map((spec) {
      final (svid, constellation, baseCn0, az, el) = spec;
      // Add slight noise to signal strength
      final cn0 = (baseCn0 + math.sin(_tick * 0.3 + svid) * 2.0 +
              _random.nextDouble() * 1.5)
          .clamp(0.0, 50.0);
      final usedInFix = cn0 > 20.0 && el > 10.0;
      return SatelliteInfo(
        svid: svid,
        constellation: constellation,
        cn0DbHz: cn0,
        azimuthDegrees: az,
        elevationDegrees: el,
        carrierFrequencyHz: constellation == GnssConstellation.gps
            ? 1575420000.0
            : constellation == GnssConstellation.galileo
                ? 1575420000.0
                : null,
        usedInFix: usedInFix,
        hasAlmanac: true,
        hasEphemeris: usedInFix,
        hasCn0: true,
      );
    }).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
