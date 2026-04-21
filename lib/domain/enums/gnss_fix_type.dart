enum GnssFixType {
  none,
  searching,
  fix2D,
  fix3D;

  String get displayName {
    switch (this) {
      case GnssFixType.none:
        return 'No Fix';
      case GnssFixType.searching:
        return 'Searching';
      case GnssFixType.fix2D:
        return '2D Fix';
      case GnssFixType.fix3D:
        return '3D Fix';
    }
  }

  bool get hasFix =>
      this == GnssFixType.fix2D || this == GnssFixType.fix3D;
}

enum LocationSource {
  gnss,
  network,
  fused,
  unknown;

  String get displayName {
    switch (this) {
      case LocationSource.gnss:
        return 'GPS';
      case LocationSource.network:
        return 'Network';
      case LocationSource.fused:
        return 'Fused';
      case LocationSource.unknown:
        return 'Unknown';
    }
  }
}
