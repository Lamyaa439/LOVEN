import 'package:loven/core/network/api_constants.dart';
import 'package:loven/core/storage/token_storage.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';
import 'package:loven/features/cart/data/repositories/cart_repository.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';

import 'fixtures.dart';

/// Single [ApiClient] for preview repositories (no requests are sent).
final ApiClient previewApiClient = ApiClient(tokenStorage: TokenStorage());

/// In-memory artist repository for profile / art-details previews.
class PreviewArtistRepository extends ArtistRepository {
  PreviewArtistRepository({
    ArtistModel? profile,
    List<ArtworkModel>? artworks,
    this.loadingDelay = Duration.zero,
    this.failOnFetch = false,
  })  : profile = profile ?? PreviewFixtures.sampleArtist,
        artworks = artworks ?? PreviewFixtures.sampleArtworks,
        super(apiClient: previewApiClient);

  final ArtistModel profile;
  final List<ArtworkModel> artworks;
  final Duration loadingDelay;
  final bool failOnFetch;

  Future<void> _maybeDelay() async {
    if (loadingDelay > Duration.zero) {
      await Future<void>.delayed(loadingDelay);
    }
  }

  void _maybeFail() {
    if (failOnFetch) {
      throw Exception('Preview: failed to load artist profile');
    }
  }

  @override
  Future<ArtistModel> getMyProfile() async {
    await _maybeDelay();
    _maybeFail();
    return profile;
  }

  @override
  Future<ArtistModel> getArtistById(String profileId) async {
    await _maybeDelay();
    _maybeFail();
    return profile;
  }

  @override
  Future<List<ArtworkModel>> listMyArtworks({
    int limit = 50,
    int offset = 0,
  }) async {
    await _maybeDelay();
    _maybeFail();
    return artworks;
  }

  @override
  Future<List<ArtworkModel>> listArtworksForProfile(
    String profileId, {
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    await _maybeDelay();
    _maybeFail();
    return artworks;
  }
}

/// Returns a fixed cart for Widgetbook cart-screen states.
class PreviewCartRepository extends CartRepository {
  PreviewCartRepository(this._cart) : super(apiClient: previewApiClient);

  final CartModel _cart;

  @override
  Future<CartModel> getCart({bool includeArtwork = true}) async => _cart;

  @override
  Future<void> addToCart({
    required String artworkId,
    required int quantity,
  }) async {}

  @override
  Future<void> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {}

  @override
  Future<void> removeCartItem({required String itemId}) async {}

  @override
  Future<void> clearCart() async {}
}

/// No-op order repository so checkout buttons do not hit the network.
class PreviewOrderRepository extends OrderRepository {
  PreviewOrderRepository() : super(apiClient: previewApiClient);

  @override
  Future<Map<String, dynamic>> createOrder({
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    return {'id': 'preview-order-1'};
  }
}
