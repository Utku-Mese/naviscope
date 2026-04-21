import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Educational reference: GNSS, GPS, how fixes work, accuracy, platform notes.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final sections = <({IconData icon, String title, String body})>[
      (
        icon: Icons.public_outlined,
        title: l10n.learnSec1Title,
        body: l10n.learnSec1Body,
      ),
      (
        icon: Icons.satellite_alt_outlined,
        title: l10n.learnSec2Title,
        body: l10n.learnSec2Body,
      ),
      (
        icon: Icons.calculate_outlined,
        title: l10n.learnSec3Title,
        body: l10n.learnSec3Body,
      ),
      (
        icon: Icons.tune_outlined,
        title: l10n.learnSec4Title,
        body: l10n.learnSec4Body,
      ),
      (
        icon: Icons.explore_outlined,
        title: l10n.learnSec5Title,
        body: l10n.learnSec5Body,
      ),
      (
        icon: Icons.smartphone_outlined,
        title: l10n.learnSec6Title,
        body: l10n.learnSec6Body,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.learnScreenTitle, style: AppTypography.screenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 20, color: AppColors.accentCyan),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.learnIntroTitle,
                        style: AppTypography.sectionHeader,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.learnIntroBody,
                  style: AppTypography.bodySecondary.copyWith(height: 1.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...sections.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LearnExpansion(
                  icon: s.icon,
                  title: s.title,
                  body: s.body,
                ),
              )),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warningAmber.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.warningAmber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.learnDisclaimer,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warningAmber.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
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

class _LearnExpansion extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _LearnExpansion({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border),
    );

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: border,
          collapsedShape: border,
          leading: Icon(icon, color: AppColors.accentCyan, size: 22),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            title,
            style: AppTypography.sectionHeader.copyWith(fontSize: 13),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                body,
                style: AppTypography.bodySecondary.copyWith(height: 1.58),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
