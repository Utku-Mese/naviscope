import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../domain/models/satellite_info.dart';

class SignalBar extends StatelessWidget {
  final SatelliteInfo satellite;
  final double barWidth;
  final double maxHeight;

  const SignalBar({
    super.key,
    required this.satellite,
    this.barWidth = 6,
    this.maxHeight = 56,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final strength = satellite.signalStrength;
    final color = satellite.constellation.color;
    final barHeight = (strength * maxHeight).clamp(2.0, maxHeight);

    return Tooltip(
      message: l10n.satelliteTooltipCn0(
        satellite.svidLabel,
        satellite.cn0DbHz.toStringAsFixed(1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: satellite.usedInFix
                  ? color
                  : color.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
              ),
              boxShadow: satellite.usedInFix
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, -1),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class SignalBarsRow extends StatelessWidget {
  final List<SatelliteInfo> satellites;
  final double maxHeight;

  const SignalBarsRow({
    super.key,
    required this.satellites,
    this.maxHeight = 56,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (satellites.isEmpty) {
      return SizedBox(
        height: maxHeight,
        child: Center(
          child: Text(
            l10n.noSatellites,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: maxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: satellites.map((sat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: SignalBar(
              satellite: sat,
              barWidth: 5,
              maxHeight: maxHeight,
            ),
          );
        }).toList(),
      ),
    );
  }
}
