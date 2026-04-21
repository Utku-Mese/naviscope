import 'satellite_info.dart';
import '../enums/gnss_fix_type.dart';
import '../enums/gnss_constellation.dart';

class GnssSnapshot {
  final List<SatelliteInfo> satellites;
  final int satellitesVisible;
  final int satellitesUsedInFix;
  final GnssFixType fixType;
  final DateTime timestamp;

  const GnssSnapshot({
    required this.satellites,
    required this.satellitesVisible,
    required this.satellitesUsedInFix,
    required this.fixType,
    required this.timestamp,
  });

  factory GnssSnapshot.fromMap(Map<String, dynamic> map) {
    final rawSats = map['satellites'] as List<dynamic>? ?? [];
    final sats = rawSats
        .map((s) => SatelliteInfo.fromMap(Map<String, dynamic>.from(s as Map)))
        .toList();
    return GnssSnapshot(
      satellites: sats,
      satellitesVisible: (map['satellitesVisible'] as num?)?.toInt() ??
          sats.length,
      satellitesUsedInFix: (map['satellitesUsedInFix'] as num?)?.toInt() ??
          sats.where((s) => s.usedInFix).length,
      fixType: _fixTypeFromString(map['fixType'] as String? ?? 'none'),
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['timestamp'] as num).toInt(),
              isUtc: true,
            )
          : DateTime.now().toUtc(),
    );
  }

  static GnssFixType _fixTypeFromString(String s) {
    switch (s) {
      case 'fix3D':
        return GnssFixType.fix3D;
      case 'fix2D':
        return GnssFixType.fix2D;
      case 'searching':
        return GnssFixType.searching;
      default:
        return GnssFixType.none;
    }
  }

  /// Satellites grouped by constellation.
  Map<GnssConstellation, List<SatelliteInfo>> get byConstellation {
    final result = <GnssConstellation, List<SatelliteInfo>>{};
    for (final sat in satellites) {
      result.putIfAbsent(sat.constellation, () => []).add(sat);
    }
    return result;
  }

  /// Average CN0 of satellites used in fix.
  double? get averageCn0 {
    final used = satellites.where((s) => s.usedInFix && s.hasCn0).toList();
    if (used.isEmpty) return null;
    return used.map((s) => s.cn0DbHz).reduce((a, b) => a + b) / used.length;
  }

  /// Composite quality score 0–100.
  int get qualityScore {
    if (fixType == GnssFixType.none || fixType == GnssFixType.searching) {
      return 0;
    }
    // Satellite count component (0–40 pts, saturates at 12 satellites)
    final satScore = (satellitesUsedInFix / 12.0).clamp(0.0, 1.0) * 40;
    // Signal strength component (0–40 pts)
    final cn0 = averageCn0 ?? 0;
    final cn0Score = (cn0 / 40.0).clamp(0.0, 1.0) * 40;
    // Fix type component (0–20 pts)
    final fixScore = fixType == GnssFixType.fix3D ? 20.0 : 10.0;
    return (satScore + cn0Score + fixScore).round().clamp(0, 100);
  }
}
