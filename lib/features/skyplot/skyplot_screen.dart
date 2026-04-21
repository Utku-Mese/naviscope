import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/enums/gnss_constellation.dart';
import '../../l10n/extensions/gnss_constellation_l10n.dart';
import '../../shared/painters/skyplot_painter.dart';
import '../../shared/widgets/platform_limit_widget.dart';
import '../../state/providers.dart';

class SkyplotScreen extends ConsumerStatefulWidget {
  const SkyplotScreen({super.key});

  @override
  ConsumerState<SkyplotScreen> createState() => _SkyplotScreenState();
}

class _SkyplotScreenState extends ConsumerState<SkyplotScreen> {
  double _elevationMask = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final capAsync = ref.watch(deviceCapabilitiesProvider);
    final frameAsync = ref.watch(telemetryStreamProvider);

    return Scaffold(
      body: capAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (caps) {
          if (!caps.hasGnssStatus) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.background,
                  title: Text(l10n.skyViewTitle),
                ),
                SliverFillRemaining(
                  child: caps.isIOS
                      ? PlatformLimitWidget(
                          title: l10n.skyViewUnavailableTitle,
                          message: l10n.skyViewUnavailableBody,
                          platformNote: l10n.skyViewUnavailableNote,
                          icon: Icons.radar_outlined,
                        )
                      : PlatformLimitWidget.androidApiTooLow(context),
                ),
              ],
            );
          }

          return frameAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (frame) {
              final gnss = frame.gnss;
              if (gnss == null || gnss.satellites.isEmpty) {
                final needsFine = caps.isAndroid &&
                    !caps.hasFineLocationPermission;
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        needsFine
                            ? Icons.gps_off_outlined
                            : Icons.radar_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        needsFine
                            ? l10n.capLimitPermission
                            : l10n.acquiringSatellites,
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: AppColors.background,
                    title: Row(
                      children: [
                        Text(l10n.skyViewTitle),
                        const SizedBox(width: 12),
                        Text(
                          l10n.skyVisibleCount(gnss.satellitesVisible),
                          style: AppTypography.primaryValue.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(
                              painter: SkyplotPainter(
                                satellites: gnss.satellites,
                                elevationMask: _elevationMask,
                                ringLabel30: l10n.skyplotRing30,
                                ringLabel60: l10n.skyplotRing60,
                                cardinalNorth: l10n.cardinalNorth,
                                cardinalEast: l10n.cardinalEast,
                                cardinalSouth: l10n.cardinalSouth,
                                cardinalWest: l10n.cardinalWest,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ElevationMaskControl(
                          value: _elevationMask,
                          onChanged: (v) =>
                              setState(() => _elevationMask = v),
                        ),
                        const SizedBox(height: 16),
                        _SkyplotLegend(
                          constellations: gnss.byConstellation.keys.toList(),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ElevationMaskControl extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _ElevationMaskControl({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.elevationMask, style: AppTypography.fieldLabel),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(0)}°',
                style: AppTypography.denseValue.copyWith(
                  color: AppColors.accentCyan,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accentCyan,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.accentCyan,
              overlayColor: AppColors.accentCyan.withValues(alpha: 0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 45,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyplotLegend extends StatelessWidget {
  final List<GnssConstellation> constellations;

  const _SkyplotLegend({required this.constellations});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.legend, style: AppTypography.fieldLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendItem(
                  label: l10n.legendUsedInFix,
                  isUsed: true,
                  color: AppColors.accentCyan),
              _LegendItem(
                  label: l10n.legendNotInFix,
                  isUsed: false,
                  color: AppColors.textTertiary),
              ...constellations.map((c) => _ConstellationLegendItem(c)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final bool isUsed;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.isUsed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isUsed ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _ConstellationLegendItem extends StatelessWidget {
  final GnssConstellation constellation;

  const _ConstellationLegendItem(this.constellation);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: constellation.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          constellation.localizedDisplayName(l10n),
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
