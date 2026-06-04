import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/routes/account_routes.dart';
import 'package:loven/core/router/routes/admin_routes.dart';
import 'package:loven/core/router/routes/auth_routes.dart';
import 'package:loven/core/router/routes/commerce_routes.dart';
import 'package:loven/core/router/routes/discovery_routes.dart';
import 'package:loven/core/router/routes/startup_routes.dart';

/// Assembles the full [GoRouter] route list in registration order.
///
/// Path matching is by [AppRoutes] constants, not list order; this order mirrors
/// the pre-split [app_router] for reviewability.
List<RouteBase> buildAppRouteList(AppRouterDeps deps) {
  return [
    ...buildStartupRoutes(deps),
    ...buildAccountRoutesHub(deps),
    ...buildCommerceRoutesEarly(deps),
    ...buildAdminRoutes(deps),
    ...buildAuthRoutesPrimary(deps),
    ...buildDiscoveryRoutesBrowse(deps),
    ...buildCommerceRoutesCheckout(deps),
    ...buildDiscoveryRoutesSettings(deps),
    ...buildAccountRoutesEdit(deps),
    ...buildCommerceRoutesCart(deps),
    ...buildDiscoveryRoutesArtistEdit(deps),
    ...buildAuthRoutesSignup(deps),
    ...buildCommerceRoutesVerification(deps),
  ];
}
