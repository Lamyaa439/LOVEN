import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/cart/data/models/cart_item_model.dart';
import 'package:loven/features/cart/data/models/cart_model.dart';

/// Shared sample models for Widgetbook previews (no network).
class PreviewFixtures {
  PreviewFixtures._();

  static const sampleArtist = ArtistModel(
    id: 'artist-profile-1',
    userId: 'user-1',
    displayName: 'Sara Al-Harbi',
    city: 'Riyadh',
    bio: 'Contemporary painter exploring light and desert landscapes.',
    profileImageUrl: null,
    isVerified: true,
    shippingPolicy: 'Ships within 3–5 business days across Saudi Arabia.',
  );

  static final sampleArtworks = <ArtworkModel>[
    const ArtworkModel(
      id: 'artwork-1',
      artistProfileId: 'artist-profile-1',
      artistDisplayName: 'Sara Al-Harbi',
      artistIsVerified: true,
      title: 'Desert Horizon',
      description: 'Acrylic on canvas, 60×80 cm.',
      price: 1200,
      quantityAvailable: 3,
      shippingFee: 45,
      artworkImageUrl:
          'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800',
    ),
    const ArtworkModel(
      id: 'artwork-2',
      artistProfileId: 'artist-profile-1',
      artistDisplayName: 'Sara Al-Harbi',
      artistIsVerified: true,
      title: 'Night Market',
      description: 'Oil on linen.',
      price: 890,
      quantityAvailable: 1,
      shippingFee: 35,
      artworkImageUrl:
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800',
    ),
  ];

  static final sampleArtwork = sampleArtworks.first;

  static final sampleOutOfStockArtwork = ArtworkModel(
    id: 'artwork-oos',
    artistProfileId: 'artist-profile-2',
    artistDisplayName: 'Guest Artist',
    title: 'Sold Out Piece',
    description: 'No longer available.',
    price: 500,
    quantityAvailable: 0,
    shippingFee: 25,
    artworkImageUrl: sampleArtwork.artworkImageUrl,
  );

  static final sampleCart = CartModel(
    id: 'cart-1',
    items: [
      CartItemModel(
        id: 'line-1',
        artworkId: 'artwork-1',
        title: 'Desert Horizon',
        imageUrl: sampleArtwork.artworkImageUrl,
        price: 1200,
        shippingFee: 45,
        quantity: 1,
        stockQuantity: 3,
      ),
      CartItemModel(
        id: 'line-2',
        artworkId: 'artwork-2',
        title: 'Night Market',
        imageUrl: sampleArtworks[1].artworkImageUrl,
        price: 890,
        shippingFee: 35,
        quantity: 2,
        stockQuantity: 2,
      ),
    ],
    subtotal: 2980,
    shippingFee: 115,
    totalAmount: 3095,
  );

  static final emptyCart = CartModel(
    items: [],
    subtotal: 0,
    shippingFee: 0,
    totalAmount: 0,
  );

  static List<Map<String, dynamic>> get sampleFavoriteMaps =>
      sampleArtworks.map((art) => art.toJson()).toList();
}
