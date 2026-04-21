import '../enums/gnss_constellation.dart';

bool _platformBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is num) return value != 0;
  final s = value.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

class SatelliteInfo {
  final int svid;
  final GnssConstellation constellation;
  final double cn0DbHz;
  final double azimuthDegrees;
  final double elevationDegrees;
  final double? carrierFrequencyHz;
  final bool usedInFix;
  final bool hasAlmanac;
  final bool hasEphemeris;
  final bool hasCn0;

  const SatelliteInfo({
    required this.svid,
    required this.constellation,
    required this.cn0DbHz,
    required this.azimuthDegrees,
    required this.elevationDegrees,
    this.carrierFrequencyHz,
    required this.usedInFix,
    this.hasAlmanac = false,
    this.hasEphemeris = false,
    this.hasCn0 = true,
  });

  factory SatelliteInfo.fromMap(Map<String, dynamic> map) {
    return SatelliteInfo(
      svid: (map['svid'] as num).toInt(),
      constellation: GnssConstellation.fromAndroidType(
          (map['constellationType'] as num?)?.toInt() ?? 0),
      cn0DbHz: (map['cn0DbHz'] as num).toDouble(),
      azimuthDegrees: (map['azimuthDegrees'] as num).toDouble(),
      elevationDegrees: (map['elevationDegrees'] as num).toDouble(),
      carrierFrequencyHz: map['carrierFrequencyHz'] != null
          ? (map['carrierFrequencyHz'] as num).toDouble()
          : null,
      usedInFix: _platformBool(map['usedInFix']),
      hasAlmanac: _platformBool(map['hasAlmanac']),
      hasEphemeris: _platformBool(map['hasEphemeris']),
      hasCn0: _platformBool(map['hasCn0'], fallback: true),
    );
  }

  /// Signal strength normalized to 0.0–1.0 (based on 0–50 dBHz range).
  double get signalStrength => (cn0DbHz / 50.0).clamp(0.0, 1.0);

  /// Human-readable carrier band label if frequency is known.
  String? get carrierBandLabel {
    if (carrierFrequencyHz == null) return null;
    final mhz = carrierFrequencyHz! / 1e6;
    if (mhz >= 1574 && mhz <= 1576) return 'L1';
    if (mhz >= 1226 && mhz <= 1228) return 'L2';
    if (mhz >= 1175 && mhz <= 1177) return 'L5';
    if (mhz >= 1598 && mhz <= 1606) return 'G1';
    if (mhz >= 1242 && mhz <= 1249) return 'G2';
    if (mhz >= 1559 && mhz <= 1563) return 'E1';
    if (mhz >= 1190 && mhz <= 1215) return 'E5';
    if (mhz >= 1164 && mhz <= 1189) return 'E5a';
    if (mhz >= 1207 && mhz <= 1215) return 'E5b';
    if (mhz >= 1559 && mhz <= 1563) return 'B1';
    if (mhz >= 1166 && mhz <= 1218) return 'B2';
    return '${mhz.toStringAsFixed(1)} MHz';
  }

  String get svidLabel => '${constellation.shortName}-$svid';
}
