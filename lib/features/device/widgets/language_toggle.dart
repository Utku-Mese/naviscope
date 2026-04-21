import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../state/locale_notifier.dart';

/// EN / TR switch — persists via [LocaleNotifier].
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final notifier = ref.read(localeProvider.notifier);

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
          Text(l10n.languageSection, style: AppTypography.fieldLabel),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LangChip(
                  label: l10n.languageEnglish,
                  code: 'en',
                  selected: locale.languageCode == 'en',
                  onTap: () => notifier.setLocale(const Locale('en')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LangChip(
                  label: l10n.languageTurkish,
                  code: 'tr',
                  selected: locale.languageCode == 'tr',
                  onTap: () => notifier.setLocale(const Locale('tr')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColors.accentCyan : AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentCyan.withValues(alpha: 0.12)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.accentCyan.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Text(
                code.toUpperCase(),
                style: AppTypography.denseValue.copyWith(
                  color: accent,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(color: accent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
