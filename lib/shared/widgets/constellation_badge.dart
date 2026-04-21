import 'package:flutter/material.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/enums/gnss_constellation.dart';

class ConstellationBadge extends StatelessWidget {
  final GnssConstellation constellation;
  final bool compact;

  const ConstellationBadge({
    super.key,
    required this.constellation,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = constellation.color;
    final label = compact ? constellation.shortName : constellation.shortName;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(
          color: color,
          fontSize: compact ? 9 : 10,
        ),
      ),
    );
  }
}

class ConstellationDot extends StatelessWidget {
  final GnssConstellation constellation;
  final double size;

  const ConstellationDot({
    super.key,
    required this.constellation,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: constellation.color,
        shape: BoxShape.circle,
      ),
    );
  }
}
