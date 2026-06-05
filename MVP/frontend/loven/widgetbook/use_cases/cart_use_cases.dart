import 'package:loven/features/cart/view/widgets/cart_preview.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:loven/features/cart/view/widgets/checkout_preview.dart';

final cartUseCases = WidgetbookComponent(
  name: 'Cart',
  useCases: [
    WidgetbookUseCase(
      name: 'Cart UI',
      builder: (context) {
        return const CartPreview();
      },
    ),

    WidgetbookUseCase(
      name: 'Checkout - Shipping',
      builder: (context) {
        return const CheckoutPreview(
          step: CheckoutStep.shipping,
        );
      },
    ),

    WidgetbookUseCase(
      name: 'Checkout - Payment',
      builder: (context) {
        return const CheckoutPreview(
          step: CheckoutStep.payment,
        );
      },
    ),

    WidgetbookUseCase(
      name: 'Checkout - Review',
      builder: (context) {
        return const CheckoutPreview(
          step: CheckoutStep.review,
        );
      },
    ),
  ],
);