import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/telemetry_frame.dart';
import 'providers.dart';

/// Maintains a rolling 60-second history of telemetry frames.
class TelemetryHistoryNotifier
    extends StateNotifier<List<TelemetryFrame>> {
  TelemetryHistoryNotifier() : super([]);

  static const _maxSamples = 60;

  void addFrame(TelemetryFrame frame) {
    final updated = [...state, frame];
    if (updated.length > _maxSamples) {
      state = updated.sublist(updated.length - _maxSamples);
    } else {
      state = updated;
    }
  }

  /// Accuracy history as Y values (meters, clamped to 0–100).
  List<double> get accuracyHistory =>
      state.map((f) => (f.location.horizontalAccuracy ?? 100.0).clamp(0, 100))
          .toList()
          .cast<double>();

  /// Speed history in km/h.
  List<double> get speedHistory =>
      state.map((f) => (f.location.speedKmh ?? 0.0).clamp(0, 200))
          .toList()
          .cast<double>();

  /// Average CN0 history.
  List<double> get cn0History =>
      state.map((f) => f.gnss?.averageCn0 ?? 0.0).toList().cast<double>();
}

final telemetryHistoryProvider =
    StateNotifierProvider<TelemetryHistoryNotifier, List<TelemetryFrame>>(
        (ref) {
  final notifier = TelemetryHistoryNotifier();

  // Subscribe to the live stream and feed the history
  ref.listen<AsyncValue<TelemetryFrame>>(telemetryStreamProvider, (_, next) {
    next.whenData(notifier.addFrame);
  });

  return notifier;
});
