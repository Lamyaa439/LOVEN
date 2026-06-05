import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] to [ChangeNotifier] for [GoRouter.refreshListenable].
///
/// Used to re-run [redirect_policy] when [AuthCubit] emits new states.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
