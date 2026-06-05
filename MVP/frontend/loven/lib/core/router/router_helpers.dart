import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fallback screen when a route is opened without required [GoRouterState.extra].
Widget invalidRouteExtraFallback({
  required String title,
  required String message,
}) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(message)),
  );
}

/// Builds [builder] when [state.extra] is a non-empty [String]; otherwise fallback.
Widget routeWithRequiredStringExtra({
  required GoRouterState state,
  required String title,
  required String missingMessage,
  required Widget Function(String value) builder,
}) {
  final raw = state.extra;
  if (raw is! String || raw.trim().isEmpty) {
    return invalidRouteExtraFallback(
      title: title,
      message: missingMessage,
    );
  }
  return builder(raw.trim());
}
