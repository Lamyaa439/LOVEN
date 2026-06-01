import 'package:flutter/material.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';
import 'package:loven/features/favorites/view/screens/favorites_screen.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../mocks/fixtures.dart';
import '../mocks/preview_cubits.dart';
import '../mocks/preview_repositories.dart';
import '../mocks/preview_shell.dart';

@widgetbook.UseCase(name: 'Loading', type: FavoritesScreen)
Widget favoritesLoadingUseCase(BuildContext context) {
  return previewShell(
    favoritesCubit: PreviewFavoritesCubit(FavoritesLoading()),
    artistRepository: PreviewArtistRepository(),
    child: const FavoritesScreen(),
  );
}

@widgetbook.UseCase(name: 'Empty', type: FavoritesScreen)
Widget favoritesEmptyUseCase(BuildContext context) {
  return previewShell(
    favoritesCubit: PreviewFavoritesCubit(
      FavoritesLoaded(
        favoriteArtworkIds: {},
        favorites: [],
      ),
    ),
    artistRepository: PreviewArtistRepository(),
    child: const FavoritesScreen(),
  );
}

@widgetbook.UseCase(name: 'With items', type: FavoritesScreen)
Widget favoritesWithItemsUseCase(BuildContext context) {
  final favorites = PreviewFixtures.sampleFavoriteMaps;

  return previewShell(
    favoritesCubit: PreviewFavoritesCubit(
      FavoritesLoaded(
        favoriteArtworkIds: favorites
            .map((item) => item['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet(),
        favorites: favorites,
      ),
    ),
    artistRepository: PreviewArtistRepository(),
    child: const FavoritesScreen(),
  );
}

@widgetbook.UseCase(name: 'Error', type: FavoritesScreen)
Widget favoritesErrorUseCase(BuildContext context) {
  return previewShell(
    favoritesCubit: PreviewFavoritesCubit(
      FavoritesError('Failed to load favorites.'),
    ),
    artistRepository: PreviewArtistRepository(),
    child: const FavoritesScreen(),
  );
}
