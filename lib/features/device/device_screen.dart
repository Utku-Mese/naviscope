import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/enums/gnss_capability_level.dart';
import '../../domain/models/device_capabilities.dart';
import '../../l10n/extensions/gnss_capability_level_l10n.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../state/providers.dart';
import '../learn/learn_screen.dart';
import 'widgets/capability_matrix.dart';
import 'widgets/language_toggle.dart';
import 'widgets/permission_card.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final capAsync = ref.watch(deviceCapabilitiesProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Text(l10n.deviceTitle),
          ),
          capAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const ShimmerStatCard(),
                  const SizedBox(height: 10),
                  const ShimmerStatCard(),
                  const SizedBox(height: 10),
                  const ShimmerStatCard(),
                ]),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                  child: Text(e.toString(),
                      style:
                          const TextStyle(color: AppColors.textSecondary))),
            ),
            data: (caps) => SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const LanguageToggle(),
                  const SizedBox(height: 12),
                  const _LearnHubCard(),
                  const SizedBox(height: 12),
                  _PlatformCard(caps: caps),
                  const SizedBox(height: 12),
                  const PermissionCard(),
                  const SizedBox(height: 12),
                  CapabilityMatrix(caps: caps),
                  const SizedBox(height: 12),
                  _LimitationCard(caps: caps),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnHubCard extends StatelessWidget {
  const _LearnHubCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => const LearnScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.accentCyan,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.learnHubCardTitle,
                      style: AppTypography.fieldLabel.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.learnHubCardSubtitle,
                      style: AppTypography.caption.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.textTertiary.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final DeviceCapabilities caps;

  const _PlatformCard({required this.caps});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levelColor = _levelColor(caps.gnssLevel);
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
              Icon(
                caps.isAndroid ? Icons.android : Icons.phone_iphone,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(l10n.platformSection, style: AppTypography.fieldLabel),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: levelColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  caps.gnssLevel.localizedBadge(l10n),
                  style:
                      AppTypography.badge.copyWith(color: levelColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
              label: l10n.rowPlatform,
              value: caps.isAndroid ? l10n.valueAndroid : l10n.valueIos),
          const SizedBox(height: 8),
          _InfoRow(label: l10n.rowOsVersion, value: caps.platformVersion),
          if (caps.deviceModel != null) ...[
            const SizedBox(height: 8),
            _InfoRow(label: l10n.rowDevice, value: caps.deviceModel!),
          ],
        ],
      ),
    );
  }

  Color _levelColor(GnssCapabilityLevel level) {
    switch (level) {
      case GnssCapabilityLevel.full:
        return AppColors.accentGreen;
      case GnssCapabilityLevel.partialAndroid:
        return AppColors.warningAmber;
      case GnssCapabilityLevel.iosLocationOnly:
        return AppColors.warningAmber;
      case GnssCapabilityLevel.permissionDenied:
        return AppColors.errorRed;
      case GnssCapabilityLevel.unavailable:
        return AppColors.errorRed;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTypography.caption),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.denseValue,
          ),
        ),
      ],
    );
  }
}

class _LimitationCard extends StatelessWidget {
  final DeviceCapabilities caps;

  const _LimitationCard({required this.caps});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = caps.gnssLevel.localizedLimitation(l10n);
    if (caps.gnssLevel == GnssCapabilityLevel.full) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warningAmber.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.warningAmber.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              size: 18, color: AppColors.warningAmber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.platformLimitationsTitle,
                  style: AppTypography.fieldLabel.copyWith(
                    color: AppColors.warningAmber,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTypography.bodySecondary.copyWith(
                    color: AppColors.warningAmber.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
