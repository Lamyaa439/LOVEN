import 'package:flutter/material.dart';
import 'package:loven/features/cart/view/screens/cart_screen.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../mocks/fixtures.dart';
import '../mocks/preview_cubits.dart';
import '../mocks/preview_shell.dart';

@widgetbook.UseCase(name: 'Loading', type: CartScreen)
Widget cartLoadingUseCase(BuildContext context) {
  return previewShell(
    cartCubit: PreviewCartCubit.loading(),
    orderCubit: PreviewOrderCubit(),
    child: const CartScreen(),
  );
}

@widgetbook.UseCase(name: 'Empty', type: CartScreen)
Widget cartEmptyUseCase(BuildContext context) {
  return previewShell(
    cartCubit: PreviewCartCubit.loaded(PreviewFixtures.emptyCart),
    orderCubit: PreviewOrderCubit(),
    child: const CartScreen(),
  );
}

@widgetbook.UseCase(name: 'With items', type: CartScreen)
Widget cartWithItemsUseCase(BuildContext context) {
  return previewShell(
    cartCubit: PreviewCartCubit.loaded(PreviewFixtures.sampleCart),
    orderCubit: PreviewOrderCubit(),
    child: const CartScreen(),
  );
}

@widgetbook.UseCase(name: 'Error', type: CartScreen)
Widget cartErrorUseCase(BuildContext context) {
  return previewShell(
    cartCubit: PreviewCartCubit.error(
      'Could not load your cart. Pull to refresh later.',
    ),
    orderCubit: PreviewOrderCubit(),
    child: const CartScreen(),
  );
}
