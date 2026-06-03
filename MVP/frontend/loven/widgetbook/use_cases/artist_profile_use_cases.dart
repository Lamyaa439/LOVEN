import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:loven/features/artist_profile/view/widgets/artist_portfolio_preview_grid.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artist_profile/view/widgets/artist_about_card.dart';
import 'package:loven/features/artist_profile/view/widgets/artist_portfolio_filter.dart';
import 'package:loven/features/artist_profile/view/widgets/artist_profile_hero_widget.dart';
import 'package:loven/features/artist_profile/view/widgets/edit_artist_profile_preview.dart';

final artistProfileUseCases = WidgetbookComponent(
  name: 'Artist Profile',
  useCases: [
    WidgetbookUseCase(
      name: 'New Artist Profile UI',
      builder: (context) {
        final artist = ArtistModel(
          id: '1',
          userId: 'user_1',
          displayName: 'Sarah Alrasheed',
          city: 'Riyadh',
          bio:
              'Contemporary artist creating soft abstract digital pieces inspired by memory, color, and Saudi landscapes.',
          shippingPolicy:
              'Ships within Saudi Arabia in 3–5 business days.',
          isVerified: true,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF2F0EF),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ArtistProfileHeroWidget(
                    artist: artist,
                    artworkCount: 12,
                    isOwner: true,
                    onUpload: () {},
                    onEdit: () {},
                  ),

                  ArtistAboutCard(
                    artist: artist,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Portfolio',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const ArtistPortfolioFilter(),

                  const SizedBox(height: 24),

                  const ArtistPortfolioPreviewGrid(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
  name: 'Edit Profile UI',
  builder: (context) {
    final artist = ArtistModel(
      id: '1',
      userId: 'user_1',
      displayName: 'Sarah Alrasheed',
      city: 'Riyadh',
      bio:
          'Contemporary artist creating soft abstract digital pieces inspired by memory, color, and Saudi landscapes.',
      shippingPolicy: 'Ships within Saudi Arabia in 3–5 business days.',
      isVerified: true,
    );

    return EditArtistProfilePreview(
      artist: artist,
    );
  },
),
  ],
);