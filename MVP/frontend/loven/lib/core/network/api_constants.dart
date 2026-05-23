import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:5000/api/v1'
      : 'http://172.17.112.1:5000/api/v1';

  // =====================================================
  // Authentication
  // =====================================================

  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String refresh = '$baseUrl/refresh';
  static const String logout = '$baseUrl/logout';

  // =====================================================
  // Artist Profiles
  // Current backend routes are mounted directly on /api/v1
  // =====================================================

  static const String createArtistProfile = baseUrl;
  static const String myArtistProfile = '$baseUrl/me';
  static const String artistProfiles = baseUrl;
  static const String artistProfileByName = '$baseUrl/by-name';

  // =====================================================
  // Cart
  // =====================================================

  static const String cart = '$baseUrl/carts/';
  static const String cartItems = '$baseUrl/carts/items';

  // =====================================================
  // Orders
  // =====================================================

  static const String orders = '$baseUrl/orders/';
  static const String myOrders = '$baseUrl/orders/mine';

  // =====================================================
  // Artworks
  // =====================================================

  static const String artworks = '$baseUrl/artworks/';
  static const String artworkSearch = '$baseUrl/artworks/search';

  static const String myArtworks = '$baseUrl/artworks/mine';

  // =====================================================
  // Feedback
  // =====================================================

  static const String feedback = '$baseUrl/feedback/';

  // =====================================================
  // Reports
  // =====================================================

  static const String reports = '$baseUrl/reports/';
}
