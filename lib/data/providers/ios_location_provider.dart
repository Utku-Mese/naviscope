import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../channels/gnss_channel.dart';
import '../../domain/enums/gnss_capability_level.dart';
import '../../domain/enums/gnss_fix_type.dart';
import '../../domain/models/device_capabilities.dart';
import '../../domain/models/location_sample.dart';
import '../../domain/models/telemetry_frame.dart';
import '../../domain/repositories/telemetry_repository.dart';

/// Location provider using geolocator — used on iOS and as a fallback on
/// Android when the custom GNSS plugin is unavailable.
///
/// On iOS, [gnss] in each [TelemetryFrame] is always null because CoreLocation
/// does not expose satellite-level data. The UI reflects this via
/// [GnssCapabilityLevel.iosLocationOnly].
class IosLocationProvider implements TelemetryRepository {
  final _controller = StreamController<TelemetryFrame>.broadcast();
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<CompassEvent>? _compassSub;
  double? _lastCompassHeading;
  DateTime? _lastCompassHeadingAt;

  static const _compassFreshWindow = Duration(seconds: 2);
  static const _minSpeedForCourseHeadingMs = 1.0;

  @override
  Stream<TelemetryFrame> get telemetryStream => _controller.stream;

  @override
  Future<DeviceCapabilities> getCapabilities() async {
    try {
      final map = await GnssChannel.getCapabilities();
      if (map.isNotEmpty) {
        return DeviceCapabilities.fromMap(map);
      }
    } catch (_) {}
    return DeviceCapabilities(
      isAndroid: false,
      isIOS: true,
      platformVersion: 'iOS',
      gnssLevel: GnssCapabilityLevel.iosLocationOnly,
      hasGnssStatus: false,
      hasGnssMeasurements: false,
      hasCarrierFrequency: false,
      hasVerticalAccuracy: true,
      hasSpeed: true,
      hasHeading: true,
      deviceModel: null,
    );
  }

  @override
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<void> startListening() async {
    _positionSub?.cancel();
    _compassSub?.cancel();
    _lastCompassHeading = null;
    _lastCompassHeadingAt = null;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );

    try {
      _compassSub = FlutterCompass.events?.listen((event) {
        final h = event.heading;
        if (h == null || h.isNaN) return;
        _lastCompassHeading = h;
        _lastCompassHeadingAt = DateTime.now();
      });
    } catch (_) {}

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      final t = DateTime.now();
      final courseHeading = (pos.heading.isNaN || pos.heading < 0)
          ? null
          : pos.heading;
      final useCourseHeading =
          pos.speed >= _minSpeedForCourseHeadingMs && courseHeading != null;
      final compassFresh = _lastCompassHeadingAt != null &&
          t.difference(_lastCompassHeadingAt!) < _compassFreshWindow;
      final fusedHeading = useCourseHeading
          ? courseHeading
          : (compassFresh ? _lastCompassHeading : null);

      final sample = LocationSample(
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitude: pos.altitude,
        speed: pos.speed,
        heading: fusedHeading,
        horizontalAccuracy: pos.accuracy,
        verticalAccuracy: pos.altitudeAccuracy,
        timestamp: pos.timestamp,
        source: LocationSource.gnss,
      );
      _controller.add(TelemetryFrame(
        location: sample,
        gnss: null,
        receivedAt: t,
      ));
    }, onError: _controller.addError);
  }

  @override
  Future<void> stopListening() async {
    await _positionSub?.cancel();
    _positionSub = null;
    await _compassSub?.cancel();
    _compassSub = null;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _compassSub?.cancel();
    _controller.close();
  }
}
