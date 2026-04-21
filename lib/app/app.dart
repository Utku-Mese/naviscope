import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../state/locale_notifier.dart';
import '../state/onboarding_notifier.dart';
import 'android_gnss_resume_listener.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

class NaviscopeApp extends ConsumerWidget {
  const NaviscopeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final onboarding = ref.watch(onboardingProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    const delegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];

    return onboarding.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.accentCyan),
          ),
        ),
      ),
      error: (_, __) => MaterialApp.router(
        onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: appRouter,
      ),
      data: (onboardingDone) {
        if (!onboardingDone) {
          return MaterialApp(
            onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            locale: locale,
            localizationsDelegates: delegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const OnboardingScreen(),
          );
        }
        return MaterialApp.router(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          locale: locale,
          localizationsDelegates: delegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            if (!Platform.isAndroid) return child;
            return AndroidGnssResumeListener(child: child);
          },
        );
      },
    );
  }
}
