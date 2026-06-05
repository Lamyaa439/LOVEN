import 'package:shared_preferences/shared_preferences.dart';

/// App-level feature flags persisted across launches (non-secret).
///
/// **Ownership (frozen contract):**
/// - Onboarding completion ([hasCompletedOnboarding], [setOnboardingCompleted])
/// - In-memory mirror updated synchronously after [init] for router redirects
///
/// **Does not belong here:** auth tokens, user profile fields, cart/order state,
/// or theme/locale (use dedicated storage or cubits when introduced).
///
/// Load via [init] from composition root ([main]) before [runApp] so
/// [redirect_policy] can read onboarding synchronously on first redirect.
class AppPreferences {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  bool _hasCompletedOnboarding = false;
  SharedPreferences? _prefs;

  /// In-memory value; accurate after [init] or [setOnboardingCompleted].
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Loads persisted flags. Required before relying on [hasCompletedOnboarding].
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding =
        _prefs!.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Marks onboarding complete; updates memory immediately, then persists.
  Future<void> setOnboardingCompleted() async {
    _hasCompletedOnboarding = true;
    await _prefs?.setBool(_onboardingCompletedKey, true);
  }
}
