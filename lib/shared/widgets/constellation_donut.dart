import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/enums/gnss_constellation.dart';
import '../../domain/models/gnss_snapshot.dart';

class ConstellationDonut extends StatelessWidget {
  final GnssSnapshot gnss;

  const ConstellationDonut({super.key, required this.gnss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final byConstellation = gnss.byConstellation;
    if (byConstellation.isEmpty) return const SizedBox.shrink();

    final sections = byConstellation.entries.map((entry) {
      final count = entry.value.length;
      final color = entry.key.color;
      return PieChartSectionData(
        value: count.toDouble(),
        color: color,
        radius: 24,
        showTitle: false,
      );
    }).toList();

    final total = gnss.satellitesVisible;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.constellationsTitle, style: AppTypography.fieldLabel),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 26,
                        startDegreeOffset: -90,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total.toString(),
                          style: AppTypography.primaryValue.copyWith(
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(l10n.satCenterLabel, style: AppTypography.fieldLabel),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: byConstellation.entries.map((entry) {
                    final used =
                        entry.value.where((s) => s.usedInFix).length;
                    return _LegendItem(
                      constellation: entry.key,
                      visible: entry.value.length,
                      used: used,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final GnssConstellation constellation;
  final int visible;
  final int used;

  const _LegendItem({
    required this.constellation,
    required this.visible,
    required this.used,
  });

  @override
  Widget build(BuildContext context) {
    final color = constellation.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          constellation.shortName,
          style: AppTypography.monoSmall.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(width: 4),
        Text(
          '$used/$visible',
          style: AppTypography.monoSmall,
        ),
      ],
    );
  }
}
