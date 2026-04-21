import 'package:flutter/services.dart';

/// Dart-side wrapper around the native naviscope/gnss MethodChannel
/// and naviscope/telemetry_stream EventChannel.
///
/// The actual native implementation lives in:
///   Android: android/app/src/main/kotlin/.../GnssTelemetryPlugin.kt
///   iOS:     ios/Runner/AppDelegate.swift
class GnssChannel {
  static const _method = MethodChannel('naviscope/gnss');
  static const _event = EventChannel('naviscope/telemetry_stream');

  /// Returns device capability map from native side.
  static Future<Map<String, dynamic>> getCapabilities() async {
    final result = await _method.invokeMethod<Map>('getCapabilities');
    return Map<String, dynamic>.from(result ?? {});
  }

  /// Tells native side to begin emitting location + GNSS updates.
  static Future<void> startListening() async {
    await _method.invokeMethod('startListening');
  }

  /// Tells native side to stop updates.
  static Future<void> stopListening() async {
    await _method.invokeMethod('stopListening');
  }

  /// Requests the OS location permission through native side.
  static Future<String> requestPermission() async {
    final result =
        await _method.invokeMethod<String>('requestPermission');
    return result ?? 'denied';
  }

  /// Raw stream of telemetry frames from native EventChannel.
  static Stream<Map<String, dynamic>> get rawStream {
    return _event.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }
}
