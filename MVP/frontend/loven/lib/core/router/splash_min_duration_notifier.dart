import 'package:flutter/foundation.dart';

/// Signals when the splash screen has shown its minimum branded duration.
///
/// The router waits for this before leaving [AppRoutes.splash] so auth redirect
/// does not cut the splash animation short.
class SplashMinDurationNotifier extends ChangeNotifier {
  bool _ready = false;

  bool get isReady => _ready;

  void markReady() {
    if (_ready) return;
    _ready = true;
    notifyListeners();
  }
}
