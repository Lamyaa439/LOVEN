import 'package:shared_preferences/shared_preferences.dart';

/// Persists lightweight app-level flags such as onboarding completion.
///
/// Loaded once at startup in [main] before [runApp] so the router can read
/// onboarding state synchronously during redirects.
class AppPreferences {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  bool _hasCompletedOnboarding = false;
  SharedPreferences? _prefs;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Loads persisted values; call from [main] before the widget tree mounts.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding =
        _prefs!.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Marks onboarding as seen and updates in-memory state immediately.
  Future<void> setOnboardingCompleted() async {
    _hasCompletedOnboarding = true;
    await _prefs?.setBool(_onboardingCompletedKey, true);
  }
}
