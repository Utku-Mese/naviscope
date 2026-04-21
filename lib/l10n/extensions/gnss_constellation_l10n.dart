import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/enums/gnss_constellation.dart';

extension GnssConstellationL10n on GnssConstellation {
  String localizedDisplayName(AppLocalizations l10n) {
    switch (this) {
      case GnssConstellation.gps:
        return l10n.constellationGps;
      case GnssConstellation.glonass:
        return l10n.constellationGlonass;
      case GnssConstellation.galileo:
        return l10n.constellationGalileo;
      case GnssConstellation.beidou:
        return l10n.constellationBeidou;
      case GnssConstellation.qzss:
        return l10n.constellationQzss;
      case GnssConstellation.sbas:
        return l10n.constellationSbas;
      case GnssConstellation.unknown:
        return l10n.constellationUnknown;
    }
  }
}
