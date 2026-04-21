import 'dart:async';
import 'dart:io';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/permissions/permission_handler.dart';
import '../channels/gnss_channel.dart';
import '../../domain/enums/gnss_capability_level.dart';
import '../../domain/enums/gnss_fix_type.dart';
import '../../domain/models/device_capabilities.dart';
import '../../domain/models/gnss_snapshot.dart';
import '../../domain/models/location_sample.dart';
import '../../domain/models/telemetry_frame.dart';
import '../../domain/repositories/telemetry_repository.dart';

/// Android GNSS provider: native [GnssTelemetryPlugin] stream plus a
/// Geolocator stream so fused / network fixes still arrive when
/// [LocationManager] GPS is idle (common on emulators and some indoor cases).
class AndroidGnssProvider implements TelemetryRepository {
  final _controller = StreamController<TelemetryFrame>.broadcast();
  StreamSubscription<Map<String, dynamic>>? _nativeSub;
  StreamSubscription<Position>? _geoSub;
  StreamSubscription<CompassEvent>? _compassSub;
  GnssSnapshot? _lastGnss;
  DateTime? _lastNativeFrameAt;
  double? _lastCompassHeading;
  DateTime? _lastCompassHeadingAt;

  static const _nativeFreshWindow = Duration(seconds: 2);
  static const _compassFreshWindow = Duration(seconds: 2);
  static const _minSpeedForCourseHeadingMs = 1.0;

  @override
  Stream<TelemetryFrame> get telemetryStream => _controller.stream;

  @override
  Future<DeviceCapabilities> getCapabilities() async {
    // Always ask native — permission (fine vs coarse) can change in Settings
    // without recreating this repository instance.
    try {
      final map = await GnssChannel.getCapabilities();
      return DeviceCapabilities.fromMap(map);
    } catch (_) {
      return DeviceCapabilities(
        isAndroid: Platform.isAndroid,
        isIOS: false,
        platformVersion: 'Android',
        gnssLevel: GnssCapabilityLevel.partialAndroid,
        hasGnssStatus: false,
        hasGnssMeasurements: false,
        hasCarrierFrequency: false,
        hasVerticalAccuracy: false,
        hasSpeed: true,
        hasHeading: true,
      );
    }
  }

  @override
  Future<bool> requestPermission() async {
    final handler = NaviPermissionHandler();
    var status = await handler.checkLocationPermission();
    if (status == NaviPermissionStatus.granted) return true;
    if (status == NaviPermissionStatus.permanentlyDenied) return false;
    status = await handler.requestLocationPermission();
    return status == NaviPermissionStatus.granted;
  }

  @override
  Future<void> startListening() async {
    await _nativeSub?.cancel();
    await _geoSub?.cancel();
    await _compassSub?.cancel();
    _lastGnss = null;
    _lastNativeFrameAt = null;
    _lastCompassHeading = null;
    _lastCompassHeadingAt = null;

    try {
      _nativeSub = GnssChannel.rawStream.listen(
        (map) {
          try {
            final frame = TelemetryFrame.fromMap(map);
            // Location-only native frames are high-frequency; do not use them to
            // suppress Geolocator or we never merge cached GNSS onto fused fixes.
            if (frame.gnss != null) {
              _lastNativeFrameAt = DateTime.now();
              _lastGnss = frame.gnss;
            }
            _controller.add(frame);
          } catch (e) {
            _controller.addError(e);
          }
        },
        onError: _controller.addError,
      );
    } catch (e) {
      _controller.addError(e);
    }

    // Re-run native startListening so [registerGnssStatusIfNeeded] can attach
    // after precise location is enabled in system settings (stream may stay up).
    if (Platform.isAndroid) {
      try {
        await GnssChannel.startListening();
      } catch (_) {}
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );
    try {
      _geoSub = Geolocator.getPositionStream(locationSettings: settings).listen(
        (pos) => _emitFusedIfNeeded(pos),
        onError: (_) {},
      );
    } catch (_) {}

    try {
      _compassSub = FlutterCompass.events?.listen((event) {
        final h = event.heading;
        if (h == null || h.isNaN) return;
        _lastCompassHeading = h;
        _lastCompassHeadingAt = DateTime.now();
      });
    } catch (_) {}

    unawaited(_bootstrapGeoPosition());
  }

  Future<void> _bootstrapGeoPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      _emitFusedIfNeeded(pos);
    } catch (_) {}
  }

  void _emitFusedIfNeeded(Position pos) {
    final t = DateTime.now();
    final nativeFresh = _lastNativeFrameAt != null &&
        t.difference(_lastNativeFrameAt!) < _nativeFreshWindow;
    if (nativeFresh) return;

    final courseHeading = (pos.heading.isNaN || pos.heading < 0)
        ? null
        : pos.heading;
    final useCourseHeading =
        pos.speed >= _minSpeedForCourseHeadingMs && courseHeading != null;
    final compassFresh = _lastCompassHeadingAt != null &&
        t.difference(_lastCompassHeadingAt!) < _compassFreshWindow;
    final fusedHeading =
        useCourseHeading ? courseHeading : (compassFresh ? _lastCompassHeading : null);

    final sample = LocationSample(
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: pos.altitude,
      speed: pos.speed,
      heading: fusedHeading,
      horizontalAccuracy: pos.accuracy,
      verticalAccuracy: pos.altitudeAccuracy,
      timestamp: pos.timestamp,
      source: LocationSource.fused,
    );
    _controller.add(TelemetryFrame(
      location: sample,
      gnss: _lastGnss,
      receivedAt: t,
    ));
  }

  @override
  Future<void> stopListening() async {
    await _nativeSub?.cancel();
    _nativeSub = null;
    await _geoSub?.cancel();
    _geoSub = null;
    await _compassSub?.cancel();
    _compassSub = null;
    try {
      await GnssChannel.stopListening();
    } catch (_) {}
  }

  @override
  void dispose() {
    _nativeSub?.cancel();
    _geoSub?.cancel();
    _compassSub?.cancel();
    _controller.close();
  }
}
