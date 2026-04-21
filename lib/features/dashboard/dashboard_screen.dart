import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/enums/gnss_fix_type.dart';
import '../../shared/widgets/constellation_donut.dart';
import '../../shared/widgets/live_indicator.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/platform_limit_widget.dart';
import '../../shared/widgets/sparkline_chart.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_banner.dart';
import '../../state/providers.dart';
import '../../state/telemetry_notifier.dart';
import 'widgets/fix_quality_badge.dart';
import 'widgets/hero_position_card.dart';
import 'widgets/metric_grid.dart';
import 'widgets/satellite_summary_strip.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final frameAsync = ref.watch(telemetryStreamProvider);
    final capAsync = ref.watch(deviceCapabilitiesProvider);
    final history = ref.watch(telemetryHistoryProvider);
    final historyNotifier = ref.read(telemetryHistoryProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 0,
            title: Row(
              children: [
                Text(l10n.brandNaviscope),
                const SizedBox(width: 8),
                frameAsync.when(
                  data: (_) => const LiveIndicator(isLive: true),
                  loading: () => LiveIndicator(
                    isLive: false,
                    label: l10n.stateLoading,
                  ),
                  error: (_, __) => LiveIndicator(
                    isLive: false,
                    label: l10n.stateError,
                  ),
                ),
                const Spacer(),
                capAsync.when(
                  data: (caps) => frameAsync.when(
                    data: (frame) {
                      final fix = frame.gnss?.fixType ??
                          (caps.hasGnssStatus
                              ? GnssFixType.searching
                              : GnssFixType.none);
                      return FixQualityBadge(
                        fixType: fix,
                        qualityScore: frame.gnss?.qualityScore,
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            backgroundColor: AppColors.background,
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 8, bottom: 32),
            sliver: frameAsync.when(
              data: (frame) {
                final caps = capAsync.valueOrNull;
                final em = l10n.emDash;
                return SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatusBanner(context, frame.gnss?.fixType),
                    const SizedBox(height: 16),
                    HeroPositionCard(
                      latitude: frame.location.latitude,
                      longitude: frame.location.longitude,
                      isLive: true,
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      label: l10n.dashAltitude,
                      value: frame.location.altitude != null
                          ? frame.location.altitude!.toStringAsFixed(1)
                          : em,
                      unit: l10n.dashAltUnitMsl,
                      size: StatCardSize.primary,
                      isLive: true,
                      subLabel: frame.location.altitude != null
                          ? l10n.dashAltSublabel(
                              (frame.location.altitude! * 3.28084)
                                  .toStringAsFixed(0),
                              frame.location.verticalAccuracy != null
                                  ? _fmtAcc(frame.location.verticalAccuracy!)
                                  : em,
                            )
                          : em,
                    ),
                    const SizedBox(height: 10),
                    MetricGrid(
                      location: frame.location,
                      gnss: frame.gnss,
                    ),
                    const SizedBox(height: 10),
                    _TimestampCard(timestamp: frame.location.timestamp),
                    const SizedBox(height: 16),
                    if (frame.gnss != null)
                      SatelliteSummaryStrip(gnss: frame.gnss!)
                    else if (caps?.gnssLevel.isIosLimited == true)
                      const _IosLocationNote()
                    else
                      const SizedBox.shrink(),
                    if (frame.gnss != null) ...[
                      const SizedBox(height: 10),
                      ConstellationDonut(gnss: frame.gnss!),
                    ],
                    if (history.length >= 5) ...[
                      const SizedBox(height: 10),
                      SparklineChart(
                        values: historyNotifier.accuracyHistory,
                        label: l10n.dashSparkAccuracy,
                        unit: l10n.unitMeters,
                        color: AppColors.accentCyan,
                        minY: 0,
                        maxY: 50,
                      ),
                      const SizedBox(height: 10),
                      SparklineChart(
                        values: historyNotifier.speedHistory,
                        label: l10n.dashSparkSpeed,
                        unit: l10n.unitKmh,
                        color: AppColors.accentViolet,
                        minY: 0,
                        maxY: 60,
                      ),
                      if (historyNotifier.cn0History
                          .any((v) => v > 0)) ...[
                        const SizedBox(height: 10),
                        SparklineChart(
                          values: historyNotifier.cn0History,
                          label: l10n.dashSparkCn0,
                          unit: l10n.cn0Unit,
                          color: AppColors.accentGreen,
                          minY: 0,
                          maxY: 50,
                        ),
                      ],
                    ],
                  ]),
                );
              },
              loading: () => SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  const ShimmerStatCard(),
                  const SizedBox(height: 10),
                  const ShimmerStatCard(),
                  const SizedBox(height: 10),
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
                ]),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: PlatformLimitWidget(
                    title: l10n.locationUnavailableTitle,
                    message: error.toString(),
                    icon: Icons.gps_off_outlined,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtAcc(double v) =>
      v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Widget _buildStatusBanner(BuildContext context, GnssFixType? fixType) {
    if (fixType == null) {
      return const StatusBanner(status: BannerStatus.searching);
    }
    switch (fixType) {
      case GnssFixType.fix3D:
      case GnssFixType.fix2D:
        return const StatusBanner(status: BannerStatus.live);
      case GnssFixType.searching:
        return const StatusBanner(status: BannerStatus.searching);
      case GnssFixType.none:
        return const StatusBanner(status: BannerStatus.error);
    }
  }
}

class _TimestampCard extends StatelessWidget {
  final DateTime timestamp;

  const _TimestampCard({required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final utcFmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    final localFmt = DateFormat('HH:mm:ss z');
    final local = timestamp.toLocal();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.schedule_outlined,
              size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${utcFmt.format(timestamp)}${l10n.timestampUtcSuffix}',
                style: AppTypography.denseValue,
              ),
              Text(
                localFmt.format(local),
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IosLocationNote extends StatelessWidget {
  const _IosLocationNote();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 18, color: AppColors.warningAmber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.iosSatelliteNote,
              style: AppTypography.caption
                  .copyWith(color: AppColors.warningAmber),
            ),
          ),
        ],
      ),
    );
  }
}
