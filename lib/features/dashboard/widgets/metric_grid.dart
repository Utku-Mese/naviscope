import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../domain/models/location_sample.dart';
import '../../../domain/models/gnss_snapshot.dart';

class MetricGrid extends StatelessWidget {
  final LocationSample? location;
  final GnssSnapshot? gnss;
  final bool isLoading;

  const MetricGrid({
    super.key,
    this.location,
    this.gnss,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Column(
        children: [
          Row(children: [
            const Expanded(child: ShimmerStatCard()),
            const SizedBox(width: 10),
            const Expanded(child: ShimmerStatCard()),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Expanded(child: ShimmerStatCard()),
            const SizedBox(width: 10),
            const Expanded(child: ShimmerStatCard()),
          ]),
        ],
      );
    }

    final loc = location;
    final speedKmh = loc?.speedKmh;
    final heading = loc?.heading;
    final hAcc = loc?.horizontalAccuracy;
    final vAcc = loc?.verticalAccuracy;
    final alt = loc?.altitude;
    final em = l10n.emDash;

    // Smart accuracy formatting — drop decimals when value is large to avoid overflow.
    String fmtAcc(double v) =>
        v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

    // Always supply a subLabel so all four cards keep identical height.
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: l10n.dashAltitude,
                value: alt != null ? alt.toStringAsFixed(1) : em,
                unit: l10n.unitMeters,
                size: StatCardSize.secondary,
                isLive: alt != null,
                subLabel: alt != null
                    ? '${(alt * 3.28084).toStringAsFixed(0)} ft'
                    : em,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: l10n.dashSpeed,
                value: speedKmh != null ? speedKmh.toStringAsFixed(1) : em,
                unit: l10n.unitKmh,
                size: StatCardSize.secondary,
                isLive: speedKmh != null,
                subLabel: speedKmh != null
                    ? '${loc!.speedKnots!.toStringAsFixed(1)} ${l10n.unitKnots}'
                    : em,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: l10n.dashHeading,
                value: heading != null ? heading.toStringAsFixed(1) : em,
                unit: heading != null ? l10n.unitDegrees : null,
                size: StatCardSize.secondary,
                isLive: heading != null,
                // Compass label when moving; preserve height with em-dash otherwise.
                subLabel: heading != null ? _headingLabel(l10n, heading) : em,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: l10n.dashAccuracy,
                value: hAcc != null ? fmtAcc(hAcc) : em,
                unit: l10n.unitMeters,
                size: StatCardSize.secondary,
                isLive: hAcc != null,
                subLabel: vAcc != null
                    ? l10n.dashVertAccLine(fmtAcc(vAcc))
                    : em,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _headingLabel(AppLocalizations l10n, double deg) {
    final dirs = [
      l10n.headingN,
      l10n.headingNE,
      l10n.headingE,
      l10n.headingSE,
      l10n.headingS,
      l10n.headingSW,
      l10n.headingW,
      l10n.headingNW,
    ];
    final idx = ((deg + 22.5) / 45).floor() % 8;
    return dirs[idx];
  }
}
