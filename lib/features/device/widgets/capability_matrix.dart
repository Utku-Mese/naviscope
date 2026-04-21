import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/models/device_capabilities.dart';

class CapabilityMatrix extends StatelessWidget {
  final DeviceCapabilities caps;

  const CapabilityMatrix({super.key, required this.caps});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final entries = [
      _CapEntry(
        label: l10n.capGnssHardware,
        supported: caps.hasGnssStatus || caps.isIOS,
        note: null,
      ),
      _CapEntry(
        label: l10n.capGnssStatusApi,
        supported: caps.hasGnssStatus,
        note: caps.isIOS ? l10n.capNoteIosNotAvailable : l10n.capNoteAndroidApi24,
      ),
      _CapEntry(
        label: l10n.capSatelliteTelemetry,
        supported: caps.hasGnssStatus,
        note: caps.isIOS ? l10n.capNoteIosNotExposed : null,
      ),
      _CapEntry(
        label: l10n.capCarrierFrequency,
        supported: caps.hasCarrierFrequency,
        note: caps.isAndroid ? l10n.capNoteAndroidApi26 : l10n.capNoteIosNotAvailable,
      ),
      _CapEntry(
        label: l10n.capRawMeasurements,
        supported: caps.hasGnssMeasurements,
        note: caps.isIOS ? l10n.capNoteIosNotAvailable : l10n.capNoteAndroidApi24,
      ),
      _CapEntry(
        label: l10n.capVerticalAccuracy,
        supported: caps.hasVerticalAccuracy,
        note: caps.isAndroid ? l10n.capNoteAndroidApi26 : l10n.capNoteIos10,
      ),
      _CapEntry(
        label: l10n.capSpeed,
        supported: caps.hasSpeed,
        note: null,
      ),
      _CapEntry(
        label: l10n.capHeading,
        supported: caps.hasHeading,
        note: null,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(l10n.capabilitiesSection, style: AppTypography.fieldLabel),
          ),
          const Divider(height: 1),
          ...entries.map((entry) {
            final isLast = entry == entries.last;
            return Column(
              children: [
                _CapabilityRow(entry: entry, l10n: l10n),
                if (!isLast)
                  const Divider(height: 1, indent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CapEntry {
  final String label;
  final bool supported;
  final String? note;

  const _CapEntry({
    required this.label,
    required this.supported,
    this.note,
  });
}

class _CapabilityRow extends StatelessWidget {
  final _CapEntry entry;
  final AppLocalizations l10n;

  const _CapabilityRow({required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color =
        entry.supported ? AppColors.accentGreen : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Icon(
            entry.supported ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: AppTypography.body.copyWith(
                    color: entry.supported
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (entry.note != null)
                  Text(
                    entry.note!,
                    style: AppTypography.caption,
                  ),
              ],
            ),
          ),
          Text(
            entry.supported ? l10n.deviceYes : l10n.deviceNo,
            style: AppTypography.badge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
