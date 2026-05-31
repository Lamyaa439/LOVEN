import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/bloc/home_bloc.dart';
import '../../controller/bloc/home_state.dart';
import '../../controller/bloc/home_event.dart';

import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/cart/controller/cubit/cart_state.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import '../widgets/art_card.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  final bool isGuest;

  const HomeScreen({
    super.key,
    this.isGuest = false,
  });

  void _goToSignup(BuildContext context) {
    context.push('/signup?fromGuest=true');
  }

Future<void> _addArtworkToCart({
  required BuildContext context,
  required ArtworkModel art,
}) async {
  final artworkId = art.id;

  if (artworkId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Artwork ID missing'),
      ),
    );
    return;
  }

  final stock = art.quantityAvailable ?? 0;

  if (stock <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This artwork is out of stock.'),
      ),
    );
    return;
  }

  int currentCartQuantity = 0;

  final cartState = context.read<CartCubit>().state;

  if (cartState is CartLoaded) {
    for (final item in cartState.cart.items) {
      if (item.artworkId == artworkId) {
        currentCartQuantity = item.quantity;
        break;
      }
    }
  }

  if (currentCartQuantity >= stock) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          stock == 1
              ? 'Only 1 item is available in stock.'
              : 'Only $stock items are available in stock.',
        ),
      ),
    );
    return;
  }

  await context.read<CartCubit>().addItem(
        artworkId: artworkId,
        quantity: 1,
      );

  await context.read<CartCubit>().getCart();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${art.title} added to cart'),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(child: Text(state.message));
            }

            if (state is HomeLoaded) {
              final artworks = state.artPieces;
              final featured = artworks.take(5).toList();
              final newArrivals = artworks.skip(1).take(5).toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    _buildHeader(context),
                    const SizedBox(height: 18),
                    _buildSearchBar(theme, context),
                    const SizedBox(height: 18),
                    _buildHeroBanner(context),
                    const SizedBox(height: 22),
                    _buildCategories(
                      context,
                      state.categories,
                      state.selectedCategory,
                    ),
                    const SizedBox(height: 26),

                    _buildSectionHeader(
                      context: context,
                      title: 'Featured Artworks',
                      onSeeAll: () {
                        context.push('/artworks-list/featured');
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildArtworkList(
                      context: context,
                      artworks: featured,
                    ),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      context: context,
                      title: 'New Arrivals',
                      onSeeAll: () {
                        context.push('/artworks-list/new-arrivals');
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildArtworkList(
                      context: context,
                      artworks:
                          newArrivals.isEmpty
                              ? featured
                              : newArrivals,
                    ),

                    const SizedBox(height: 28),

                    _buildArtistPreviewSection(
                      context,
                      artworks,
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Start exploring art!'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Home',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              context.push('/notifications');
            },
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Local Artists',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Discover original artworks from emerging creators.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                      color: theme.colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.primary,
                      foregroundColor:
                          theme.colorScheme.onPrimary,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      minimumSize:
                          const Size(0, 34),
                      tapTargetSize:
                          MaterialTapTargetSize
                              .shrinkWrap,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          999,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Explore Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 92,
              height: 104,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary
                    .withOpacity(0.12),
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.palette_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onSeeAll,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See all',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkList({
    required BuildContext context,
    required List<ArtworkModel> artworks,
  }) {
    if (artworks.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 22),
        child: Text('No artworks found.'),
      );
    }

    return SizedBox(
      height: 255,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 22),
        itemCount: artworks.length,
        itemBuilder: (context, index) {
          final art = artworks[index];

          return ArtCard(
            artwork: art,
            isGuest: isGuest,
            onActionPressed: () async {
  final isActuallyGuest =
      isGuest || context.read<AuthCubit>().state is AuthGuest;

  if (isActuallyGuest) {
    context.push('/auth');
    return;
  }

  await _addArtworkToCart(
    context: context,
    art: art,
  );
},
          );
        },
      ),
    );
  }

  Widget _buildArtistPreviewSection(
    BuildContext context,
    List<ArtworkModel> artworks,
  ) {
    final theme = Theme.of(context);

    final artistItems = artworks
        .where(
          (art) =>
              art.artistProfileId != null &&
              art.artistProfileId!.isNotEmpty,
        )
        .toList();

    if (artistItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Artists',
          onSeeAll: () {
            context.push('/artists');
          },
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.only(left: 22),
            itemCount: artistItems.length,
            itemBuilder: (context, index) {
              final artwork =
                  artistItems[index];

              return GestureDetector(
                onTap: () {
                  final artistId =
                      artwork.artistProfileId;

                  if (artistId == null ||
                      artistId.isEmpty) {
                    return;
                  }

                  context.push(
                    '/artist/$artistId',
                  );
                },
                child: Container(
                  width: 92,
                  margin:
                      const EdgeInsets.only(
                    right: 18,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundImage:
                            artwork.artistProfileImageUrl !=
                                    null
                                ? NetworkImage(
                                    artwork
                                        .artistProfileImageUrl!,
                                  )
                                : null,
                        backgroundColor: theme
                            .colorScheme.primary
                            .withOpacity(0.12),
                        child: artwork
                                    .artistProfileImageUrl ==
                                null
                            ? Icon(
                                Icons.person_rounded,
                                color: theme
                                    .colorScheme
                                    .primary,
                                size: 34,
                              )
                            : null,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Flexible(
                            child: Text(
                              artwork.artistDisplayName ??
                                  'Artist',
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),

                          if (artwork
                              .artistIsVerified) ...[
                            const SizedBox(
                              width: 4,
                            ),

                            Icon(
                              Icons
                                  .verified_rounded,
                              size: 16,
                              color: theme
                                  .colorScheme
                                  .primary,
                            ),
                          ],
                        ],
                      ),

                      Text(
                        'Creator',
                        style: theme
                            .textTheme.bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurface
                              .withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    ThemeData theme,
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor
                  .withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: (text) {
            context.read<HomeBloc>().add(
                  FilterArtworks(
                    searchText: text,
                  ),
                );
          },
          decoration: InputDecoration(
            hintText:
                'Search artworks, artists, styles...',
            hintStyle: TextStyle(
              color: theme.colorScheme
                  .onSurface
                  .withOpacity(0.45),
              fontSize: 14,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: Icon(
              Icons.tune_rounded,
              color: theme.colorScheme
                  .onSurface
                  .withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(
    BuildContext context,
    List<String> categories,
    String selectedCategory,
  ) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 22),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categoryName =
              categories[index];

          final isSelected =
              categoryName ==
                  selectedCategory;

          return Padding(
            padding:
                const EdgeInsets.only(right: 10),
            child: _buildCategoryCard(
              context,
              categoryName,
              isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(
              FilterArtworks(
                category: title,
              ),
            );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius:
              BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor
                    .withOpacity(0.4),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: theme.textTheme.bodySmall
                ?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme
                      .onSurface
                      .withOpacity(0.7),
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}