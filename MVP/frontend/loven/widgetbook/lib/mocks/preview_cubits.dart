import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/repositories/auth_repository.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/controller/cubit/cart_state.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';
import 'package:loven/features/favorites/data/repositories/favorites_repository.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/artwork/data/repositories/artwork_repository.dart';

import 'fixtures.dart';
import 'preview_repositories.dart';

/// Pre-seeded [CartCubit] that skips network refresh on [getCart].
class PreviewCartCubit extends CartCubit {
  PreviewCartCubit._(CartState initial, CartModel cart)
      : super(PreviewCartRepository(cart)) {
    emit(initial);
  }

  factory PreviewCartCubit.loaded(CartModel cart) =>
      PreviewCartCubit._(CartLoaded(cart), cart);

  factory PreviewCartCubit.loading() =>
      PreviewCartCubit._(CartLoading(), PreviewFixtures.emptyCart);

  factory PreviewCartCubit.error(String message) =>
      PreviewCartCubit._(CartError(message), PreviewFixtures.emptyCart);

  @override
  Future<void> getCart() async {
    // [CartScreen.initState] calls this — keep the seeded preview state.
  }
}

/// Pre-seeded [FavoritesCubit] for favorites / art-details previews.
class PreviewFavoritesCubit extends FavoritesCubit {
  PreviewFavoritesCubit(FavoritesState initial)
      : super(FavoritesRepository(apiClient: previewApiClient)) {
    emit(initial);
  }

  @override
  Future<void> loadFavorites() async {}

  @override
  Future<void> toggleFavorite(String artworkId) async {}
}

/// [AuthCubit] with a fixed initial state (login screen previews).
class PreviewAuthCubit extends AuthCubit {
  PreviewAuthCubit(AuthState initial)
      : super(
          authRepository: AuthRepository(
            apiClient: previewApiClient,
            tokenStorage: TokenStorage(),
          ),
          tokenStorage: TokenStorage(),
        ) {
    emit(initial);
  }
}

/// Inert order cubit for cart checkout row.
class PreviewOrderCubit extends OrderCubit {
  PreviewOrderCubit() : super(PreviewOrderRepository());
}

/// Inert artwork cubit for artist profile grid actions.
class PreviewArtworkCubit extends ArtworkCubit {
  PreviewArtworkCubit()
      : super(ArtworkRepository(apiClient: previewApiClient));

  @override
  Future<void> deleteArtwork({required String artworkId}) async {}
}
