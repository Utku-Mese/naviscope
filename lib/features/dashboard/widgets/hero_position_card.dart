import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class HeroPositionCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isLive;

  const HeroPositionCard({
    super.key,
    this.latitude,
    this.longitude,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final em = l10n.emDash;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive
              ? AppColors.accentCyan.withValues(alpha: 0.4)
              : AppColors.border,
        ),
        boxShadow: isLive
            ? [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.07),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.positionLabel,
            style: AppTypography.fieldLabel,
          ),
          const SizedBox(height: 16),
          _CoordinateRow(
            label: l10n.latLabel,
            value: latitude != null
                ? _formatCoord(latitude!, 'N', 'S')
                : em,
            isLive: isLive,
          ),
          const SizedBox(height: 10),
          _CoordinateRow(
            label: l10n.lonLabel,
            value: longitude != null
                ? _formatCoord(longitude!, 'E', 'W')
                : em,
            isLive: isLive,
          ),
          const SizedBox(height: 10),
          _DecimalRow(latitude: latitude, longitude: longitude, emDash: em),
        ],
      ),
    );
  }

  String _formatCoord(double value, String pos, String neg) {
    final isNeg = value < 0;
    final abs = value.abs();
    final deg = abs.floor();
    final min = (abs - deg) * 60;
    final minInt = min.floor();
    final sec = (min - minInt) * 60;
    final dir = isNeg ? neg : pos;
    return '$dir ${deg.toString().padLeft(3, '0')}°'
        ' ${minInt.toString().padLeft(2, '0')}′'
        ' ${sec.toStringAsFixed(3).padLeft(6, '0')}″';
  }
}

class _CoordinateRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLive;

  const _CoordinateRow({
    required this.label,
    required this.value,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: AppTypography.fieldLabel,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
              final slide = Tween<Offset>(
                begin: const Offset(0.0, 0.08),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                key: ValueKey(value),
                value,
                style: AppTypography.primaryValue.copyWith(
                  color: isLive ? AppColors.textPrimary : AppColors.textTertiary,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DecimalRow extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String emDash;

  const _DecimalRow({
    this.latitude,
    this.longitude,
    required this.emDash,
  });

  @override
  Widget build(BuildContext context) {
    final text = latitude != null && longitude != null
        ? '${latitude!.toStringAsFixed(7)}, ${longitude!.toStringAsFixed(7)}'
        : '$emDash, $emDash';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          key: ValueKey(text),
          text,
          style: AppTypography.monoSmall.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
