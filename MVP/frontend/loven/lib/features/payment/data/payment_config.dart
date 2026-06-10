import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class PaymentConfig {
  static String get publishableKey =>
      dotenv.env['MOYASAR_PUBLISHABLE_KEY'] ?? '';
}