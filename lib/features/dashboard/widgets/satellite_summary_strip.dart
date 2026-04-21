import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/models/gnss_snapshot.dart';
import '../../../domain/enums/gnss_constellation.dart';
import '../../../domain/enums/gnss_fix_type.dart';
import '../../../l10n/extensions/gnss_fix_type_l10n.dart';
import '../../../shared/widgets/signal_bar.dart';

class SatelliteSummaryStrip extends StatelessWidget {
  final GnssSnapshot gnss;

  const SatelliteSummaryStrip({super.key, required this.gnss});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final byConstellation = gnss.byConstellation;

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
          Row(
            children: [
              Text(l10n.satellitesSection, style: AppTypography.fieldLabel),
              const Spacer(),
              _QualityScore(score: gnss.qualityScore, l10n: l10n),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CountChip(
                value: gnss.satellitesVisible,
                label: l10n.countVisible,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              _CountChip(
                value: gnss.satellitesUsedInFix,
                label: l10n.countUsed,
                color: AppColors.accentGreen,
              ),
              const Spacer(),
              _FixTypeBadge(fixType: gnss.fixType, l10n: l10n),
            ],
          ),
          const SizedBox(height: 12),
          SignalBarsRow(
            satellites: gnss.satellites
                .where((s) => s.hasCn0)
                .toList()
              ..sort((a, b) => b.cn0DbHz.compareTo(a.cn0DbHz)),
            maxHeight: 40,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: byConstellation.entries.map((entry) {
              final count = entry.value.length;
              final used =
                  entry.value.where((s) => s.usedInFix).length;
              return _ConstellationChip(
                constellation: entry.key,
                visible: count,
                used: used,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _CountChip({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value.toString(),
          style: AppTypography.primaryValue.copyWith(color: color, fontSize: 22),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.fieldLabel),
      ],
    );
  }
}

class _FixTypeBadge extends StatelessWidget {
  final GnssFixType fixType;
  final AppLocalizations l10n;

  const _FixTypeBadge({required this.fixType, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isGood = fixType == GnssFixType.fix3D;
    final color = isGood ? AppColors.accentGreen : AppColors.warningAmber;
    final label = fixType.localizedName(l10n).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(color: color),
      ),
    );
  }
}

class _ConstellationChip extends StatelessWidget {
  final GnssConstellation constellation;
  final int visible;
  final int used;

  const _ConstellationChip({
    required this.constellation,
    required this.visible,
    required this.used,
  });

  @override
  Widget build(BuildContext context) {
    final color = constellation.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            constellation.shortName,
            style: AppTypography.monoSmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 6),
          Text(
            '$used/$visible',
            style: AppTypography.monoSmall,
          ),
        ],
      ),
    );
  }
}

class _QualityScore extends StatelessWidget {
  final int score;
  final AppLocalizations l10n;

  const _QualityScore({required this.score, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? AppColors.accentGreen
        : score >= 40
            ? AppColors.warningAmber
            : AppColors.errorRed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Tooltip(
          message: l10n.qualityScoreTooltip,
          triggerMode: TooltipTriggerMode.longPress,
          child: Text(
            '${l10n.qualityScoreLabel} $score${l10n.qualityScoreSuffix}',
            style: AppTypography.badge.copyWith(color: color),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 52,
          height: 3,
          child: LinearProgressIndicator(
            value: score / 100.0,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
