import 'package:flutter_test/flutter_test.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

void main() {

  test('ArtworkModel.fromJson parses production-shaped artwork payload', () {
    final artwork = ArtworkModel.fromJson({
      'artist_display_name': 'Nasjah',
      'artist_is_verified': false,
      'artist_profile_id': '9164fe40-736e-487f-ac6c-5f803bce5e3b',
      'artist_profile_image_url': null,
      'artwork_image_url': 'https://example.com/art.jpg',
      'created_at': '2026-06-06T17:17:53.978625',
      'description': 'test',
      'id': '7a7adecc-7beb-4012-9c2d-b0a9c7a220ed',
      'price': '40.00',
      'quantity_available': 2,
      'shipping_fee': '5.00',
      'status': 'available',
      'title': 'title',
      'updated_at': '2026-06-06T17:17:53.978629',
    });

    expect(artwork.id, '7a7adecc-7beb-4012-9c2d-b0a9c7a220ed');
    expect(artwork.price, 40.0);
    expect(artwork.quantityAvailable, 2);
    expect(artwork.artistIsVerified, isFalse);
  });

  test('ArtworkModel.fromJson tolerates mixed numeric and bool formats', () {
    final artwork = ArtworkModel.fromJson({
      'id': '1',
      'artist_profile_id': '2',
      'title': 'Mixed',
      'artist_is_verified': 1,
      'quantity_available': '3',
      'price': 10,
      'shipping_fee': '2.5',
    });

    expect(artwork.artistIsVerified, isTrue);
    expect(artwork.quantityAvailable, 3);
    expect(artwork.price, 10.0);
    expect(artwork.shippingFee, 2.5);
  });
}
