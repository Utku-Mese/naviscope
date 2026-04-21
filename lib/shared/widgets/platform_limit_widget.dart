import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class PlatformLimitWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? platformNote;
  final IconData icon;
  final bool fullScreen;

  const PlatformLimitWidget({
    super.key,
    required this.title,
    required this.message,
    this.platformNote,
    this.icon = Icons.satellite_alt_outlined,
    this.fullScreen = true,
  });

  factory PlatformLimitWidget.iosSatellites(BuildContext context,
      {bool fullScreen = true}) {
    final l10n = AppLocalizations.of(context)!;
    return PlatformLimitWidget(
      title: l10n.platformLimitIosSatTitle,
      message: l10n.platformLimitIosSatBody,
      platformNote: l10n.platformLimitIosSatNote,
      icon: Icons.satellite_alt_outlined,
      fullScreen: fullScreen,
    );
  }

  factory PlatformLimitWidget.androidApiTooLow(BuildContext context,
      {bool fullScreen = true}) {
    final l10n = AppLocalizations.of(context)!;
    return PlatformLimitWidget(
      title: l10n.platformLimitAndroidApiTitle,
      message: l10n.platformLimitAndroidApiBody,
      platformNote: l10n.platformLimitAndroidApiNote,
      icon: Icons.android_outlined,
      fullScreen: fullScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment:
            fullScreen ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(icon, size: 36, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTypography.primaryValue.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          if (platformNote != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.warningAmber.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.warningAmber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      platformNote!,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.warningAmber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Center(child: SingleChildScrollView(child: content));
    }
    return content;
  }
}
