import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class LiveIndicator extends StatefulWidget {
  final bool isLive;
  final String? label;
  final Color? color;

  const LiveIndicator({
    super.key,
    required this.isLive,
    this.label,
    this.color,
  });

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dotColor = widget.color ??
        (widget.isLive ? AppColors.accentGreen : AppColors.textTertiary);
    final label =
        widget.label ?? (widget.isLive ? l10n.liveLabel : l10n.offlineLabel);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: widget.isLive ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: widget.isLive
                      ? [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.badge.copyWith(color: dotColor),
        ),
      ],
    );
  }
}
