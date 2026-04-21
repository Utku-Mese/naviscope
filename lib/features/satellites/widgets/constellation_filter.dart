import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/enums/gnss_constellation.dart';

class ConstellationFilter extends StatelessWidget {
  final List<GnssConstellation> available;
  final GnssConstellation? selected;
  final bool showUsedOnly;
  final ValueChanged<GnssConstellation?> onConstellationSelected;
  final VoidCallback onToggleUsedOnly;

  const ConstellationFilter({
    super.key,
    required this.available,
    required this.selected,
    required this.showUsedOnly,
    required this.onConstellationSelected,
    required this.onToggleUsedOnly,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.filterAll,
            color: AppColors.accentCyan,
            isSelected: selected == null,
            onTap: () => onConstellationSelected(null),
          ),
          const SizedBox(width: 6),
          ...available.map((c) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _FilterChip(
                  label: c.shortName,
                  color: c.color,
                  isSelected: selected == c,
                  onTap: () => onConstellationSelected(
                      selected == c ? null : c),
                ),
              )),
          const SizedBox(width: 6),
          _FilterChip(
            label: l10n.filterUsed,
            color: AppColors.accentGreen,
            isSelected: showUsedOnly,
            onTap: onToggleUsedOnly,
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: isSelected ? color : AppColors.textTertiary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.badge.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
