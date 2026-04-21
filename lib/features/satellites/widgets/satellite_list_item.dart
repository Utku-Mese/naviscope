import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/models/satellite_info.dart';
import '../../../shared/widgets/constellation_badge.dart';

class SatelliteListItem extends StatelessWidget {
  final SatelliteInfo satellite;
  final bool hasCarrierFrequency;

  const SatelliteListItem({
    super.key,
    required this.satellite,
    this.hasCarrierFrequency = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = satellite.constellation.color;
    final isUsed = satellite.usedInFix;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUsed ? color.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: isUsed ? color : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          ConstellationBadge(constellation: satellite.constellation),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              satellite.svid.toString(),
              style: AppTypography.denseValue.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: satellite.signalStrength,
                          minHeight: 5,
                          backgroundColor: AppColors.border,
                          color: isUsed ? color : color.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      satellite.cn0DbHz.toStringAsFixed(1),
                      style: AppTypography.denseValue,
                    ),
                    const SizedBox(width: 2),
                    Text(l10n.cn0Unit, style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('${l10n.azimuthShort} ', style: AppTypography.caption),
                  Text(
                    '${satellite.azimuthDegrees.toStringAsFixed(0)}${l10n.unitDegrees}',
                    style: AppTypography.monoSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('${l10n.elevationShort} ', style: AppTypography.caption),
                  Text(
                    '${satellite.elevationDegrees.toStringAsFixed(0)}${l10n.unitDegrees}',
                    style: AppTypography.monoSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (hasCarrierFrequency && satellite.carrierBandLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentViolet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                    color: AppColors.accentViolet.withValues(alpha: 0.35)),
              ),
              child: Text(
                satellite.carrierBandLabel!,
                style: AppTypography.badge.copyWith(
                  color: AppColors.accentViolet,
                  fontSize: 9,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            isUsed ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 16,
            color: isUsed ? AppColors.accentGreen : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
