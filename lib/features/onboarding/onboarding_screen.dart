import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../state/onboarding_notifier.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _pageCount = 3;

  static const _accents = <Color>[
    AppColors.accentCyan,
    AppColors.accentViolet,
    AppColors.accentGreen,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
  }

  Color get _accent => _accents[_index.clamp(0, _pageCount - 1)];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _AmbientBackdrop(accent: _accent, pageIndex: _index),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accentCyan,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentCyan,
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.brandNaviscope,
                              style: AppTypography.badge.copyWith(
                                color: AppColors.textPrimary,
                                letterSpacing: 2.2,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.onboardingSkip,
                              style: AppTypography.bodySecondary.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      _OnboardingPage(
                        accent: _accents[0],
                        icon: Icons.radar_outlined,
                        title: l10n.onboardingSlide1Title,
                        body: l10n.onboardingSlide1Body,
                        orbitHue: 0.0,
                      ),
                      _OnboardingPage(
                        accent: _accents[1],
                        icon: Icons.satellite_alt_outlined,
                        title: l10n.onboardingSlide2Title,
                        body: l10n.onboardingSlide2Body,
                        orbitHue: 0.33,
                      ),
                      _OnboardingPage(
                        accent: _accents[2],
                        icon: Icons.map_outlined,
                        title: l10n.onboardingSlide3Title,
                        body: l10n.onboardingSlide3Body,
                        orbitHue: 0.66,
                      ),
                    ],
                  ),
                ),
                _BottomChrome(
                  accent: _accent,
                  pageIndex: _index,
                  pageCount: _pageCount,
                  onPrimary: () {
                    if (_index < _pageCount - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      _finish();
                    }
                  },
                  primaryLabel: _index < _pageCount - 1
                      ? l10n.onboardingNext
                      : l10n.onboardingGetStarted,
                  showBack: _index > 0,
                  onBack: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
                SizedBox(height: 8 + MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
          // Subtle top vignette
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPad + 56,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft colored orbs + grid noise feel without assets.
class _AmbientBackdrop extends StatelessWidget {
  final Color accent;
  final int pageIndex;

  const _AmbientBackdrop({
    required this.accent,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final phase = pageIndex * 0.12;

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _GridGlowPainter(
              accent: accent.withValues(alpha: 0.04),
            ),
            size: Size.infinite,
          ),
          Positioned(
            right: -w * 0.15 + phase * 40,
            top: h * 0.08,
            child: _GlowOrb(
              diameter: w * 0.72,
              color: accent,
              opacity: 0.14,
            ),
          ),
          Positioned(
            left: -w * 0.22 - phase * 30,
            bottom: h * 0.18,
            child: _GlowOrb(
              diameter: w * 0.58,
              color: AppColors.accentViolet,
              opacity: pageIndex == 1 ? 0.12 : 0.06,
            ),
          ),
          Positioned(
            left: w * 0.35,
            top: h * 0.42,
            child: _GlowOrb(
              diameter: w * 0.35,
              color: AppColors.accentCyan,
              opacity: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double diameter;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.diameter,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.35),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  final Color accent;

  _GridGlowPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..strokeWidth = 0.8;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridGlowPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _OnboardingPage extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String body;
  final double orbitHue;

  const _OnboardingPage({
    required this.accent,
    required this.icon,
    required this.title,
    required this.body,
    required this.orbitHue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeroIconBlock(
                  accent: accent,
                  icon: icon,
                  orbitHue: orbitHue,
                ),
                const SizedBox(height: 28),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.07),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.screenTitle.copyWith(
                              fontSize: 22,
                              height: 1.25,
                              shadows: [
                                Shadow(
                                  color: accent.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            body,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySecondary.copyWith(
                              height: 1.58,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroIconBlock extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final double orbitHue;

  const _HeroIconBlock({
    required this.accent,
    required this.icon,
    required this.orbitHue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 176,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(240, 176),
              painter: _OrbitRingsPainter(color: accent.withValues(alpha: 0.35)),
            ),
            ...List.generate(5, (i) {
              final a = (i / 5.0 + orbitHue) * 2 * math.pi;
              const rx = 82.0;
              const ry = 52.0;
              return Transform.translate(
                offset: Offset(rx * math.cos(a), ry * math.sin(a)),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.32 + i * 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.28),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              );
            }),
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.28),
                    accent.withValues(alpha: 0.08),
                    AppColors.surfaceHighest.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Icon(icon, size: 52, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  final Color color;

  _OrbitRingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 6);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;

    canvas.drawArc(
      Rect.fromCenter(center: c, width: 168, height: 108),
      0.15,
      2.35,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: c, width: 198, height: 132),
      -0.45,
      2.15,
      false,
      paint..color = color.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitRingsPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BottomChrome extends StatelessWidget {
  final Color accent;
  final int pageIndex;
  final int pageCount;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final bool showBack;
  final VoidCallback onBack;

  const _BottomChrome({
    required this.accent,
    required this.pageIndex,
    required this.pageCount,
    required this.onPrimary,
    required this.primaryLabel,
    required this.showBack,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.0),
                AppColors.background.withValues(alpha: 0.92),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pageCount, (i) {
                  final active = i == pageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: active ? 26 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active
                          ? accent
                          : AppColors.border.withValues(alpha: 0.85),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.55),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (showBack) ...[
                    OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.9),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: FilledButton(
                        onPressed: onPrimary,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              primaryLabel,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.background,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              pageIndex < pageCount - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_rounded,
                              size: 22,
                              color: AppColors.background,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
