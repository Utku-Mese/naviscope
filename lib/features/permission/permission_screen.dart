import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../state/providers.dart';

class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.satellite_alt,
                  size: 48,
                  color: AppColors.accentCyan,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.permScreenTitle,
                style: AppTypography.primaryValue.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.permScreenBody,
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _FeatureRow(
                  icon: Icons.satellite_alt_outlined,
                  text: l10n.permFeatureSatellite),
              _FeatureRow(
                  icon: Icons.place_outlined, text: l10n.permFeaturePosition),
              _FeatureRow(
                  icon: Icons.speed_outlined, text: l10n.permFeatureMotion),
              _FeatureRow(icon: Icons.map_outlined, text: l10n.permFeatureMap),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(locationPermissionProvider.notifier)
                        .request();
                  },
                  icon: const Icon(Icons.gps_fixed, size: 18),
                  label: Text(l10n.permGrantButton),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.permFooterPrivacy,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.accentCyan),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
