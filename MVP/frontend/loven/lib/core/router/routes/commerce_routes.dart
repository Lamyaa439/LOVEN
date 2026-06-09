import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_router_deps.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/features/artwork/view/screens/create_artwork_screen.dart';
import 'package:loven/features/cart/view/screens/confirm_order_screen.dart';
import 'package:loven/features/feedback/view/screens/feedback_screen.dart';
import 'package:loven/features/location/view/screens/address_form_screen.dart';
import 'package:loven/features/location/view/screens/location_screen.dart';
import 'package:loven/features/navigation/view/Screens/navigation_screen.dart';
import 'package:loven/features/notifications/view/screens/notifications_screen.dart';
import 'package:loven/features/order/view/screens/incoming_orders_screen.dart';
import 'package:loven/features/order/view/screens/order_details_screen.dart';
import 'package:loven/features/order/view/screens/order_history_screen.dart';
import 'package:loven/features/verification_request/controller/cubit/verification_request_cubit.dart';
import 'package:loven/features/verification_request/view/screens/verification_request_screen.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/cart/view/screens/checkout_screen.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';

/// Account hub, orders, cart, checkout, and related signed-in flows.
List<RouteBase> buildCommerceRoutesEarly(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) {
  return const NavigationScreen(
    initialIndex: 3,
    accountChild: NotificationsScreen(),
  );
},
    ),
    GoRoute(
      path: AppRoutes.ordersDetails,
      builder: (context, state) {
        final raw = state.extra;
        if (raw is! Map) {
          return invalidRouteExtraFallback(
            title: 'Order Details',
            message: 'Unable to open order details.',
          );
        }
        final order = Map<String, dynamic>.from(raw);
        return OrderDetailsScreen(order: order);
      },
    ),
    GoRoute(
      path: AppRoutes.ordersIncoming,
      builder: (context, state) {
        final raw = state.extra;
        if (raw is! String || raw.isEmpty) {
          return invalidRouteExtraFallback(
            title: 'Incoming Orders',
            message: 'Artist profile ID is missing.',
          );
        }
        final artistProfileId = raw;
        return NavigationScreen(
  initialIndex: 3,
  accountChild: IncomingOrdersScreen(
    artistProfileId: artistProfileId,
  ),
);
      },
    ),
    GoRoute(
      path: AppRoutes.ordersHistory,
      builder: (context, state) {
  return const NavigationScreen(
    initialIndex: 3,
    accountChild: OrderHistoryScreen(),
  );
},
    ),
  ];
}

List<RouteBase> buildCommerceRoutesCheckout(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.feedback,
      builder: (context, state) {
  return const NavigationScreen(
    initialIndex: 3,
    accountChild: FeedbackScreen(),
  );
},
    ),
    GoRoute(
      path: AppRoutes.confirmOrder,
      builder: (context, state) => const ConfirmOrderScreen(),
    ),
    GoRoute(
      path: AppRoutes.location,
      builder: (context, state) {
  return const NavigationScreen(
    initialIndex: 3,
    accountChild: LocationScreen(),
  );
},
    ),
    GoRoute(
      path: AppRoutes.locationAddressForm,
      builder: (context, state) => const AddressFormScreen(),
    ),
  ];
}

List<RouteBase> buildCommerceRoutesCart(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const NavigationScreen(initialIndex: 2),
    ),
    GoRoute(
  path: AppRoutes.artworksCreate,
  builder: (context, state) {
    return BlocProvider(
      create: (_) => ArtistProfileCubit(
        repository: deps.artistRepository,
        authCubit: deps.authCubit,
      )..fetchMyProfileData(),
      child: const CreateArtworkScreen(),
    );
  },
),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) {
        final raw = state.extra;

        if (raw is! CartModel) {
          return invalidRouteExtraFallback(
            title: 'Checkout',
            message: 'Unable to open checkout. Cart data is missing.',
          );
        }

        return CheckoutScreen(cart: raw);
      },
    ),
  ];
}

List<RouteBase> buildCommerceRoutesVerification(AppRouterDeps deps) {
  return [
    GoRoute(
      path: AppRoutes.verificationRequest,
      builder: (context, state) {
        return NavigationScreen(
  initialIndex: 3,
  accountChild: BlocProvider(
    create: (_) => VerificationRequestCubit(
      deps.verificationRequestRepository,
    ),
    child: const VerificationRequestScreen(),
  ),
);
      },
    ),
  ];
}