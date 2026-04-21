import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/enums/gnss_fix_type.dart';
import '../../../l10n/extensions/gnss_fix_type_l10n.dart';

class FixQualityBadge extends StatelessWidget {
  final GnssFixType fixType;
  final int? qualityScore;

  const FixQualityBadge({super.key, required this.fixType, this.qualityScore});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            fixType.localizedName(l10n).toUpperCase(),
            style: AppTypography.badge.copyWith(color: color),
          ),
          if (qualityScore != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 12,
              color: color.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 8),
            Text(
              '$qualityScore',
              style: AppTypography.badge.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }

  Color get _color {
    switch (fixType) {
      case GnssFixType.fix3D:
        return AppColors.accentGreen;
      case GnssFixType.fix2D:
        return AppColors.warningAmber;
      case GnssFixType.searching:
        return AppColors.accentCyan;
      case GnssFixType.none:
        return AppColors.errorRed;
    }
  }

  IconData get _icon {
    switch (fixType) {
      case GnssFixType.fix3D:
        return Icons.gps_fixed;
      case GnssFixType.fix2D:
        return Icons.gps_not_fixed;
      case GnssFixType.searching:
        return Icons.sync;
      case GnssFixType.none:
        return Icons.gps_off;
    }
  }
}
