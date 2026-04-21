import 'package:flutter/material.dart';

enum GnssConstellation {
  gps,
  glonass,
  galileo,
  beidou,
  qzss,
  sbas,
  unknown;

  String get displayName {
    switch (this) {
      case GnssConstellation.gps:
        return 'GPS';
      case GnssConstellation.glonass:
        return 'GLONASS';
      case GnssConstellation.galileo:
        return 'Galileo';
      case GnssConstellation.beidou:
        return 'BeiDou';
      case GnssConstellation.qzss:
        return 'QZSS';
      case GnssConstellation.sbas:
        return 'SBAS';
      case GnssConstellation.unknown:
        return 'Unknown';
    }
  }

  String get shortName {
    switch (this) {
      case GnssConstellation.gps:
        return 'GPS';
      case GnssConstellation.glonass:
        return 'GLO';
      case GnssConstellation.galileo:
        return 'GAL';
      case GnssConstellation.beidou:
        return 'BDS';
      case GnssConstellation.qzss:
        return 'QZSS';
      case GnssConstellation.sbas:
        return 'SBAS';
      case GnssConstellation.unknown:
        return 'UNK';
    }
  }

  // Android GnssStatus constellation type constants
  static GnssConstellation fromAndroidType(int type) {
    switch (type) {
      case 1:
        return GnssConstellation.gps;
      case 2:
        return GnssConstellation.sbas;
      case 3:
        return GnssConstellation.glonass;
      case 4:
        return GnssConstellation.qzss;
      case 5:
        return GnssConstellation.beidou;
      case 6:
        return GnssConstellation.galileo;
      case 7:
        // Android: CONSTELLATION_IRNSS (NavIC), not QZSS.
        return GnssConstellation.unknown;
      default:
        return GnssConstellation.unknown;
    }
  }

  Color get color {
    switch (this) {
      case GnssConstellation.gps:
        return const Color(0xFF00D2FF);
      case GnssConstellation.glonass:
        return const Color(0xFFFF6B6B);
      case GnssConstellation.galileo:
        return const Color(0xFFFFE455);
      case GnssConstellation.beidou:
        return const Color(0xFF55FF99);
      case GnssConstellation.qzss:
        return const Color(0xFFFF9F43);
      case GnssConstellation.sbas:
        return const Color(0xFFCC88FF);
      case GnssConstellation.unknown:
        return const Color(0xFF404F65);
    }
  }
}
