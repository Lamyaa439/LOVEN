import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:loven/core/config/app_env.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/firebase_options.dart';

/// Result of one-time async startup before [runApp].
class BootstrapResult {
  const BootstrapResult({required this.appPreferences});

  final AppPreferences appPreferences;
}

/// Runs platform and SDK initialization — no repositories or cubits.
///
/// Call from [main] only; composition continues in [AppDependencies] / [LovenApp].
Future<BootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppEnv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final appPreferences = AppPreferences();
  await appPreferences.init();

  return BootstrapResult(appPreferences: appPreferences);
}
