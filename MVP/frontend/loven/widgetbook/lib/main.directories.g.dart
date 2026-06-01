// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/use_cases/art_details_use_cases.dart'
    as _widgetbook_workspace_use_cases_art_details_use_cases;
import 'package:widgetbook_workspace/use_cases/artist_profile_use_cases.dart'
    as _widgetbook_workspace_use_cases_artist_profile_use_cases;
import 'package:widgetbook_workspace/use_cases/cart_use_cases.dart'
    as _widgetbook_workspace_use_cases_cart_use_cases;
import 'package:widgetbook_workspace/use_cases/favorites_use_cases.dart'
    as _widgetbook_workspace_use_cases_favorites_use_cases;
import 'package:widgetbook_workspace/use_cases/login_use_cases.dart'
    as _widgetbook_workspace_use_cases_login_use_cases;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'features',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'artist_profile',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'view',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'screens',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'ArtistProfileScreen',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Error',
                        builder:
                            _widgetbook_workspace_use_cases_artist_profile_use_cases
                                .artistProfileErrorUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Loading',
                        builder:
                            _widgetbook_workspace_use_cases_artist_profile_use_cases
                                .artistProfileLoadingUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Public profile',
                        builder:
                            _widgetbook_workspace_use_cases_artist_profile_use_cases
                                .artistProfilePublicUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Success',
                        builder:
                            _widgetbook_workspace_use_cases_artist_profile_use_cases
                                .artistProfileSuccessUseCase,
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'auth',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'view',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'screens',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'LoginPage',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Default',
                        builder: _widgetbook_workspace_use_cases_login_use_cases
                            .loginDefaultUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Error',
                        builder: _widgetbook_workspace_use_cases_login_use_cases
                            .loginErrorUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'From guest',
                        builder: _widgetbook_workspace_use_cases_login_use_cases
                            .loginFromGuestUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Loading',
                        builder: _widgetbook_workspace_use_cases_login_use_cases
                            .loginLoadingUseCase,
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'cart',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'view',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'screens',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'CartScreen',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Empty',
                        builder: _widgetbook_workspace_use_cases_cart_use_cases
                            .cartEmptyUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Error',
                        builder: _widgetbook_workspace_use_cases_cart_use_cases
                            .cartErrorUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Loading',
                        builder: _widgetbook_workspace_use_cases_cart_use_cases
                            .cartLoadingUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'With items',
                        builder: _widgetbook_workspace_use_cases_cart_use_cases
                            .cartWithItemsUseCase,
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'favorites',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'view',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'screens',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'FavoritesScreen',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Empty',
                        builder:
                            _widgetbook_workspace_use_cases_favorites_use_cases
                                .favoritesEmptyUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Error',
                        builder:
                            _widgetbook_workspace_use_cases_favorites_use_cases
                                .favoritesErrorUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Loading',
                        builder:
                            _widgetbook_workspace_use_cases_favorites_use_cases
                                .favoritesLoadingUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'With items',
                        builder:
                            _widgetbook_workspace_use_cases_favorites_use_cases
                                .favoritesWithItemsUseCase,
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'home',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'View',
            children: [
              _widgetbook.WidgetbookFolder(
                name: 'widgets',
                children: [
                  _widgetbook.WidgetbookComponent(
                    name: 'ArtDetailsScreen',
                    useCases: [
                      _widgetbook.WidgetbookUseCase(
                        name: 'Guest',
                        builder:
                            _widgetbook_workspace_use_cases_art_details_use_cases
                                .artDetailsGuestUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'In stock',
                        builder:
                            _widgetbook_workspace_use_cases_art_details_use_cases
                                .artDetailsInStockUseCase,
                      ),
                      _widgetbook.WidgetbookUseCase(
                        name: 'Out of stock',
                        builder:
                            _widgetbook_workspace_use_cases_art_details_use_cases
                                .artDetailsOutOfStockUseCase,
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
    ],
  )
];
