import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/artist_profile_use_cases.dart';
import 'use_cases/artwork_use_cases.dart';
import 'use_cases/cart_use_cases.dart';
import 'use_cases/location_use_cases.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
return Widgetbook.material(
  directories: [
    WidgetbookFolder(
      name: 'LOVEN',
      children: [
        artistProfileUseCases,
        artworkUseCases,
        cartUseCases,
        locationUseCases,
      ],
    ),
  ],
);
  }
}