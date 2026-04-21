import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../state/providers.dart';

class PermissionCard extends ConsumerWidget {
  const PermissionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hasPermission = ref.watch(locationPermissionProvider);
    final color =
        hasPermission ? AppColors.accentGreen : AppColors.errorRed;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasPermission ? Icons.lock_open_outlined : Icons.lock_outlined,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.locationPermissionTitle, style: AppTypography.fieldLabel),
                const SizedBox(height: 2),
                Text(
                  hasPermission
                      ? l10n.locationGrantedPrecise
                      : l10n.locationRequired,
                  style: AppTypography.body.copyWith(
                    color: hasPermission
                        ? AppColors.textPrimary
                        : AppColors.errorRed,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!hasPermission)
            TextButton(
              onPressed: () {
                ref.read(locationPermissionProvider.notifier).request();
              },
              child: Text(
                l10n.grantButton,
                style: AppTypography.body.copyWith(
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
