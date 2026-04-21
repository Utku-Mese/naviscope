import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/enums/gnss_capability_level.dart';

extension GnssCapabilityLevelL10n on GnssCapabilityLevel {
  String localizedLimitation(AppLocalizations l10n) {
    switch (this) {
      case GnssCapabilityLevel.full:
        return l10n.capLimitFull;
      case GnssCapabilityLevel.partialAndroid:
        return l10n.capLimitPartialAndroid;
      case GnssCapabilityLevel.iosLocationOnly:
        return l10n.capLimitIos;
      case GnssCapabilityLevel.permissionDenied:
        return l10n.capLimitPermission;
      case GnssCapabilityLevel.unavailable:
        return l10n.capLimitUnavailable;
    }
  }

  /// Short badge on the Device platform card.
  String localizedBadge(AppLocalizations l10n) {
    switch (this) {
      case GnssCapabilityLevel.full:
        return l10n.capLevelFull;
      case GnssCapabilityLevel.partialAndroid:
        return l10n.capLevelPartial;
      case GnssCapabilityLevel.iosLocationOnly:
        return l10n.capLevelIosLimited;
      case GnssCapabilityLevel.permissionDenied:
        return l10n.capLevelNoPermission;
      case GnssCapabilityLevel.unavailable:
        return l10n.capLevelUnavailable;
    }
  }
}
