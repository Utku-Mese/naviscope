import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum BannerStatus { live, searching, denied, error, unsupported }

class StatusBanner extends StatelessWidget {
  final BannerStatus status;
  final String? customMessage;

  const StatusBanner({
    super.key,
    required this.status,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _bgColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _bgColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 14, color: _bgColor),
            const SizedBox(width: 8),
            Text(
              customMessage ?? _defaultMessage(l10n),
              style: AppTypography.badge.copyWith(color: _bgColor),
            ),
          ],
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case BannerStatus.live:
        return AppColors.accentGreen;
      case BannerStatus.searching:
        return AppColors.accentCyan;
      case BannerStatus.denied:
        return AppColors.warningAmber;
      case BannerStatus.error:
        return AppColors.errorRed;
      case BannerStatus.unsupported:
        return AppColors.textTertiary;
    }
  }

  IconData get _icon {
    switch (status) {
      case BannerStatus.live:
        return Icons.gps_fixed;
      case BannerStatus.searching:
        return Icons.gps_not_fixed;
      case BannerStatus.denied:
        return Icons.lock_outline;
      case BannerStatus.error:
        return Icons.error_outline;
      case BannerStatus.unsupported:
        return Icons.block_outlined;
    }
  }

  String _defaultMessage(AppLocalizations l10n) {
    switch (status) {
      case BannerStatus.live:
        return l10n.statusGnssLock;
      case BannerStatus.searching:
        return l10n.statusAcquiring;
      case BannerStatus.denied:
        return l10n.statusPermissionRequired;
      case BannerStatus.error:
        return l10n.statusGnssError;
      case BannerStatus.unsupported:
        return l10n.statusNotSupported;
    }
  }
}
