import 'dart:io';
import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'locale_notifier.dart';
export 'onboarding_notifier.dart';

import '../data/providers/android_gnss_provider.dart';
import '../data/providers/ios_location_provider.dart';
import '../data/providers/mock_gnss_provider.dart';
import '../domain/models/device_capabilities.dart';
import '../domain/models/telemetry_frame.dart';
import '../domain/repositories/telemetry_repository.dart';

// Mock/synthetic telemetry (demo without hardware). Off by default so the app
// uses real GNSS/location on device. Enable with:
//   flutter run --dart-define=NAVISCOPE_MOCK=true
const bool _useMock = bool.fromEnvironment('NAVISCOPE_MOCK', defaultValue: false);

// --- Repository provider ---

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final TelemetryRepository repo;

  if (_useMock) {
    repo = MockGnssProvider();
  } else if (Platform.isAndroid) {
    // Android: try native GNSS plugin; falls back to geolocator internally
    // when the plugin channel is unavailable (e.g. emulator without plugin).
    repo = AndroidGnssProvider();
  } else if (Platform.isIOS) {
    repo = IosLocationProvider();
  } else {
    // Desktop/web — use mock for now
    repo = MockGnssProvider();
  }

  ref.onDispose(repo.dispose);
  return repo;
});

// --- Capability detection ---

final deviceCapabilitiesProvider = FutureProvider<DeviceCapabilities>((ref) {
  final repo = ref.watch(telemetryRepositoryProvider);
  return repo.getCapabilities();
});

// --- Live telemetry stream ---

final telemetryStreamProvider = StreamProvider<TelemetryFrame>((ref) async* {
  final repo = ref.watch(telemetryRepositoryProvider);
  await repo.startListening();
  yield* repo.telemetryStream;
});

// --- Latest telemetry frame (convenience) ---

final latestFrameProvider = Provider<TelemetryFrame?>((ref) {
  return ref.watch(telemetryStreamProvider).valueOrNull;
});

// --- Compass heading (high-frequency UI stream) ---
//
// Geolocator's Position.heading is course-over-ground; it can be missing or
// update slowly when the device is stationary. UI (map marker) benefits from a
// higher-frequency compass stream that keeps rotation smooth while stopped.
final compassHeadingStreamProvider = StreamProvider<double?>((ref) {
  final controller = StreamController<double?>.broadcast();
  StreamSubscription<CompassEvent>? sub;

  DateTime? lastEmitAt;
  double? lastHeading;

  double normalize(double deg) {
    final x = deg % 360.0;
    return x < 0 ? x + 360.0 : x;
  }

  double lerpAngle(double from, double to, double t) {
    final a = normalize(from);
    final b = normalize(to);
    var diff = b - a;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return normalize(a + diff * t);
  }

  try {
    sub = FlutterCompass.events?.listen((event) {
      final raw = event.heading;
      if (raw == null || raw.isNaN) return;

      // Throttle to keep rebuild cost low but still smooth.
      final now = DateTime.now();
      if (lastEmitAt != null &&
          now.difference(lastEmitAt!) < const Duration(milliseconds: 60)) {
        return;
      }
      lastEmitAt = now;

      final h = normalize(raw);
      // Light smoothing to reduce jitter without feeling laggy.
      final smoothed = lastHeading == null ? h : lerpAngle(lastHeading!, h, 0.35);
      lastHeading = smoothed;
      controller.add(smoothed);
    }, onError: (_) {});
  } catch (_) {}

  ref.onDispose(() async {
    await sub?.cancel();
    await controller.close();
  });

  return controller.stream;
});

// --- Permission state ---

final locationPermissionProvider =
    StateNotifierProvider<_PermissionNotifier, bool>((ref) {
  return _PermissionNotifier(
    ref.watch(telemetryRepositoryProvider),
    ref,
  );
});

class _PermissionNotifier extends StateNotifier<bool> {
  final TelemetryRepository _repo;
  final Ref _ref;

  _PermissionNotifier(this._repo, this._ref) : super(false) {
    _check();
  }

  Future<void> _check() async {
    final granted = await _repo.requestPermission();
    state = granted;
    if (granted) {
      _ref.invalidate(telemetryStreamProvider);
      _ref.invalidate(deviceCapabilitiesProvider);
    }
  }

  Future<void> request() async {
    final granted = await _repo.requestPermission();
    state = granted;
    if (granted) {
      // Native GNSS listener was skipped until permission existed; restart stream.
      _ref.invalidate(telemetryStreamProvider);
      _ref.invalidate(deviceCapabilitiesProvider);
    }
  }
}
