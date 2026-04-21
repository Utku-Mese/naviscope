import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/models/telemetry_frame.dart';
import '../../state/providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  bool _followPosition = true;

  @override
  Widget build(BuildContext context) {
    final frameAsync = ref.watch(telemetryStreamProvider);
    final compassHeadingAsync = ref.watch(compassHeadingStreamProvider);

    return Scaffold(
      body: frameAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (frame) {
          final loc = frame.location;
          final point = LatLng(loc.latitude, loc.longitude);
          final compassHeading = compassHeadingAsync.valueOrNull;
          final speed = loc.speed ?? 0.0;
          final displayHeading =
              (speed >= 1.0 && loc.heading != null) ? loc.heading : compassHeading;

          if (_followPosition) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _mapController.move(point, _mapController.camera.zoom);
              }
            });
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 16.0,
                  onMapEvent: (event) {
                    if (event is MapEventMove &&
                        event.source != MapEventSource.mapController) {
                      if (_followPosition) {
                        setState(() => _followPosition = false);
                      }
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.naviscope.app',
                    tileBuilder: _darkTileBuilder,
                  ),
                  // Accuracy circle
                  if (loc.horizontalAccuracy != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: point,
                          radius: loc.horizontalAccuracy!,
                          useRadiusInMeter: true,
                          color: AppColors.accentCyan.withValues(alpha: 0.08),
                          borderColor: AppColors.accentCyan.withValues(alpha: 0.4),
                          borderStrokeWidth: 1.5,
                        ),
                      ],
                    ),
                  // Position marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 48,
                        height: 48,
                        child: _PositionMarker(
                          heading: displayHeading,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // HUD overlay — top
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: _MapHud(frame: frame),
              ),
              // Follow / center button
              Positioned(
                right: 16,
                bottom: 32,
                child: _FollowButton(
                  isFollowing: _followPosition,
                  onTap: () {
                    setState(() => _followPosition = true);
                    _mapController.move(point, 16.0);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _darkTileBuilder(
      BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        0, 0, 0, 1, 0,
      ]),
      child: tileWidget,
    );
  }
}

class _PositionMarker extends StatelessWidget {
  final double? heading;

  const _PositionMarker({this.heading});

  @override
  Widget build(BuildContext context) {
    final turns = (heading ?? 0) / 360.0;
    return AnimatedRotation(
      turns: turns,
      duration: const Duration(milliseconds: 90),
      curve: Curves.linear,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.accentCyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: AppColors.background, width: 2.5),
            ),
          ),
          if (heading != null)
            Positioned(
              top: 4,
              child: Container(
                width: 4,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapHud extends StatelessWidget {
  final TelemetryFrame frame;

  const _MapHud({required this.frame});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = frame.location;
    final em = l10n.emDash;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${loc.latitude.toStringAsFixed(6)}, '
                '${loc.longitude.toStringAsFixed(6)}',
                style: AppTypography.denseValue,
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.mapHudAltPrefix}${loc.altitude?.toStringAsFixed(1) ?? em}${l10n.unitMeters}'
                '${l10n.mapHudAccSep}'
                '${l10n.mapHudAccPlusMinus}${loc.horizontalAccuracy?.toStringAsFixed(0) ?? em}${l10n.mapHudMetersSuffix}',
                style: AppTypography.caption,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(loc.speedKmh ?? 0).toStringAsFixed(1)} ${l10n.unitKmh}',
                style: AppTypography.denseValue
                    .copyWith(color: AppColors.accentCyan),
              ),
              Text(
                '${loc.heading?.toStringAsFixed(0) ?? em}${l10n.unitDegrees}',
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isFollowing
              ? AppColors.accentCyan
              : AppColors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: isFollowing ? AppColors.accentCyan : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withValues(alpha: 0.6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          isFollowing ? Icons.gps_fixed : Icons.gps_not_fixed,
          size: 20,
          color: isFollowing
              ? AppColors.textOnAccent
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
