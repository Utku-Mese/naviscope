import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingPrefsKey = 'naviscope_onboarding_completed';

/// First-launch onboarding. Persists completion in SharedPreferences.
class OnboardingNotifier extends StateNotifier<AsyncValue<bool>> {
  OnboardingNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(_onboardingPrefsKey) ?? false;
      state = AsyncValue.data(done);
    } catch (_) {
      // Do not block the app if storage fails.
      state = const AsyncValue.data(true);
    }
  }

  /// Marks onboarding as seen and updates state so the main app shows.
  Future<void> complete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingPrefsKey, true);
    } catch (_) {
      // Still proceed in memory.
    }
    state = const AsyncValue.data(true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, AsyncValue<bool>>((ref) {
  return OnboardingNotifier();
});
