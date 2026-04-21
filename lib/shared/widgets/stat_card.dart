import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

enum StatCardSize { hero, primary, secondary, compact }

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? subLabel;
  final StatCardSize size;
  final bool isLive;
  final Color? accentColor;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.subLabel,
    this.size = StatCardSize.primary,
    this.isLive = false,
    this.accentColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive
              ? (accentColor ?? AppColors.accentCyan).withValues(alpha: 0.4)
              : AppColors.border,
          width: 1,
        ),
        boxShadow: isLive
            ? [
                BoxShadow(
                  color: (accentColor ?? AppColors.accentCyan).withValues(alpha: 0.08),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: AppTypography.fieldLabel.copyWith(
                      color: accentColor?.withValues(alpha: 0.8) ??
                          AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: _labelValueGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: _valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(unit!, style: AppTypography.unit),
                ],
              ],
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                subLabel!,
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  EdgeInsets get _padding {
    switch (size) {
      case StatCardSize.hero:
        return const EdgeInsets.all(20);
      case StatCardSize.primary:
        return const EdgeInsets.all(16);
      case StatCardSize.secondary:
        return const EdgeInsets.all(14);
      case StatCardSize.compact:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    }
  }

  double get _labelValueGap {
    switch (size) {
      case StatCardSize.hero:
        return 8;
      case StatCardSize.primary:
        return 6;
      case StatCardSize.secondary:
        return 4;
      case StatCardSize.compact:
        return 2;
    }
  }

  TextStyle get _valueStyle {
    switch (size) {
      case StatCardSize.hero:
        return AppTypography.heroValue;
      case StatCardSize.primary:
        return AppTypography.primaryValue;
      case StatCardSize.secondary:
        return AppTypography.secondaryValue;
      case StatCardSize.compact:
        return AppTypography.denseValue;
    }
  }
}
