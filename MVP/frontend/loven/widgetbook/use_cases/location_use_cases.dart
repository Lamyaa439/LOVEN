import 'package:widgetbook/widgetbook.dart';

import 'package:loven/features/location/view/widgets/address_previews.dart';

final locationUseCases = WidgetbookComponent(
  name: 'Location',
  useCases: [
    WidgetbookUseCase(
      name: 'Address Selector',
      builder: (context) {
        return const AddressSelectorPreview();
      },
    ),
    WidgetbookUseCase(
      name: 'Address Book',
      builder: (context) {
        return const AddressBookPreview();
      },
    ),
    WidgetbookUseCase(
      name: 'Add Address',
      builder: (context) {
        return const AddAddressPreview();
      },
    ),
  ],
);