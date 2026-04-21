import '../models/telemetry_frame.dart';
import '../models/device_capabilities.dart';

abstract class TelemetryRepository {
  Stream<TelemetryFrame> get telemetryStream;

  Future<DeviceCapabilities> getCapabilities();

  Future<bool> requestPermission();

  Future<void> startListening();

  Future<void> stopListening();

  void dispose();
}
