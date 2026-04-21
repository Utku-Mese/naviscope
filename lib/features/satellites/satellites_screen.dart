import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/enums/gnss_constellation.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/platform_limit_widget.dart';
import '../../state/providers.dart';
import 'widgets/constellation_filter.dart';
import 'widgets/satellite_list_item.dart';
import 'widgets/signal_bars_panel.dart';

class SatellitesScreen extends ConsumerStatefulWidget {
  const SatellitesScreen({super.key});

  @override
  ConsumerState<SatellitesScreen> createState() => _SatellitesScreenState();
}

class _SatellitesScreenState extends ConsumerState<SatellitesScreen> {
  GnssConstellation? _filterConstellation;
  bool _showUsedOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final frameAsync = ref.watch(telemetryStreamProvider);
    final capAsync = ref.watch(deviceCapabilitiesProvider);

    return Scaffold(
      body: capAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (caps) {
          if (!caps.hasGnssStatus) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, null, null),
                SliverFillRemaining(
                  child: caps.isIOS
                      ? PlatformLimitWidget.iosSatellites(context)
                      : PlatformLimitWidget.androidApiTooLow(context),
                ),
              ],
            );
          }

          return frameAsync.when(
            loading: () => CustomScrollView(
              slivers: [
                _buildAppBar(context, null, null),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: const ShimmerStatCard(),
                      ),
                      childCount: 8,
                    ),
                  ),
                ),
              ],
            ),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (frame) {
              final gnss = frame.gnss;
              if (gnss == null) {
                // No satellite data yet — help the user understand why.
                final needsFinePermission = caps.isAndroid &&
                    !caps.hasFineLocationPermission;
                if (needsFinePermission) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gps_off_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noGnssData,
                            style: AppTypography.fieldLabel.copyWith(
                                color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.capLimitPermission,
                            style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () async {
                              final handler = ref.read(
                                  locationPermissionProvider.notifier);
                              await handler.request();
                            },
                            icon: const Icon(Icons.settings_outlined,
                                size: 18),
                            label: Text(l10n.grantButton),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.radar_outlined,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        l10n.acquiringSatellites,
                        style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              var sats = gnss.satellites;
              if (_filterConstellation != null) {
                sats = sats
                    .where((s) => s.constellation == _filterConstellation)
                    .toList();
              }
              if (_showUsedOnly) {
                sats = sats.where((s) => s.usedInFix).toList();
              }
              sats.sort((a, b) => b.cn0DbHz.compareTo(a.cn0DbHz));

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(
                    context,
                    gnss.satellitesVisible,
                    gnss.satellitesUsedInFix,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: SignalBarsPanel(satellites: gnss.satellites),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: ConstellationFilter(
                        available: gnss.byConstellation.keys.toList(),
                        selected: _filterConstellation,
                        showUsedOnly: _showUsedOnly,
                        onConstellationSelected: (c) =>
                            setState(() => _filterConstellation = c),
                        onToggleUsedOnly: () =>
                            setState(() => _showUsedOnly = !_showUsedOnly),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SatelliteListItem(
                              satellite: sats[index],
                              hasCarrierFrequency:
                                  caps.hasCarrierFrequency,
                            ),
                          );
                        },
                        childCount: sats.length,
                      ),
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

  SliverAppBar _buildAppBar(BuildContext context, int? visible, int? used) {
    final l10n = AppLocalizations.of(context)!;
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      title: Row(
        children: [
          Text(l10n.satellitesTitle),
          if (visible != null) ...[
            const SizedBox(width: 12),
            Text(
              '$used / $visible',
              style: AppTypography.primaryValue.copyWith(
                fontSize: 16,
                color: AppColors.accentCyan,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
