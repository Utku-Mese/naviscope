import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/models/satellite_info.dart';
import '../../../domain/enums/gnss_constellation.dart';
import '../../../shared/widgets/signal_bar.dart';

class SignalBarsPanel extends StatelessWidget {
  final List<SatelliteInfo> satellites;

  const SignalBarsPanel({super.key, required this.satellites});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final byConstellation = <GnssConstellation, List<SatelliteInfo>>{};
    for (final sat in satellites) {
      byConstellation.putIfAbsent(sat.constellation, () => []).add(sat);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.signalStrength, style: AppTypography.fieldLabel),
              const Spacer(),
              Text(l10n.scaleZero, style: AppTypography.caption),
              const SizedBox(width: 4),
              Text(l10n.scaleDash, style: AppTypography.caption),
              const SizedBox(width: 4),
              Text(l10n.scaleFiftyDbHz, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 8),
          ...byConstellation.entries.map((entry) {
            final sats = entry.value
              ..sort((a, b) => b.cn0DbHz.compareTo(a.cn0DbHz));
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      entry.key.shortName,
                      style: AppTypography.monoSmall.copyWith(
                        color: entry.key.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SignalBarsRow(satellites: sats, maxHeight: 48),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
