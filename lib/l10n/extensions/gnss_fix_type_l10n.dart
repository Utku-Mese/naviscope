import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/enums/gnss_fix_type.dart' show GnssFixType, LocationSource;

extension GnssFixTypeL10n on GnssFixType {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case GnssFixType.none:
        return l10n.fixTypeNone;
      case GnssFixType.searching:
        return l10n.fixTypeSearching;
      case GnssFixType.fix2D:
        return l10n.fixType2D;
      case GnssFixType.fix3D:
        return l10n.fixType3D;
    }
  }
}

extension LocationSourceL10n on LocationSource {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case LocationSource.gnss:
        return l10n.locationSourceGnss;
      case LocationSource.network:
        return l10n.locationSourceNetwork;
      case LocationSource.fused:
        return l10n.locationSourceFused;
      case LocationSource.unknown:
        return l10n.locationSourceUnknown;
    }
  }
}
