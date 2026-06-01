import 'package:flutter/material.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';
import 'package:loven/features/home/View/widgets/art_details_screen.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../mocks/fixtures.dart';
import '../mocks/preview_cubits.dart';
import '../mocks/preview_repositories.dart';
import '../mocks/preview_shell.dart';

@widgetbook.UseCase(name: 'Guest', type: ArtDetailsScreen)
Widget artDetailsGuestUseCase(BuildContext context) {
  return previewShell(
    child: ArtDetailsScreen(
      artItem: PreviewFixtures.sampleArtwork,
      artistRepository: PreviewArtistRepository(),
      isGuest: true,
    ),
  );
}

@widgetbook.UseCase(name: 'In stock', type: ArtDetailsScreen)
Widget artDetailsInStockUseCase(BuildContext context) {
  return previewShell(
    artistRepository: PreviewArtistRepository(),
    cartCubit: PreviewCartCubit.loaded(PreviewFixtures.emptyCart),
    favoritesCubit: PreviewFavoritesCubit(
      FavoritesLoaded(
        favoriteArtworkIds: {PreviewFixtures.sampleArtwork.id},
        favorites: PreviewFixtures.sampleFavoriteMaps,
      ),
    ),
    child: ArtDetailsScreen(
      artItem: PreviewFixtures.sampleArtwork,
      artistRepository: PreviewArtistRepository(),
      isGuest: false,
    ),
  );
}

@widgetbook.UseCase(name: 'Out of stock', type: ArtDetailsScreen)
Widget artDetailsOutOfStockUseCase(BuildContext context) {
  return previewShell(
    artistRepository: PreviewArtistRepository(),
    cartCubit: PreviewCartCubit.loaded(PreviewFixtures.emptyCart),
    favoritesCubit: PreviewFavoritesCubit(
      FavoritesLoaded(
        favoriteArtworkIds: {},
        favorites: [],
      ),
    ),
    child: ArtDetailsScreen(
      artItem: PreviewFixtures.sampleOutOfStockArtwork,
      artistRepository: PreviewArtistRepository(),
      isGuest: false,
    ),
  );
}
