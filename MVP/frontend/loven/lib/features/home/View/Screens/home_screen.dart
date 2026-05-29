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
      const SnackBar(content: Text('Artwork ID missing')),
    );
    return;
  }

  final cartState = context.read<CartCubit>().state;

  int currentCartQuantity = 0;

  if (cartState is CartLoaded) {
    for (final item in cartState.cart.items) {
      if (item.artworkId == artworkId) {
        currentCartQuantity = item.quantity;
        break;
      }
    }
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
    SnackBar(content: Text('${art.title} added to cart')),
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HomeLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildSearchBar(
                    theme,
                    context,
                  ),
                  // height between search and Boxes
                  const SizedBox(height: 26),
                  _buildCategories(
                    context,
                    state.categories,
                    state.selectedCategory,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 38.0, 16.0, 16.0),
                    child: Text(
                      'Discover and Collect Art',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  SizedBox(
                    height: 350,
                    child: state.artPieces.isEmpty
                        ? const Center(
                            child: Text(
                              'No pieces found matching filters.',
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(
                              left: 16,
                            ),
                            itemCount: state.artPieces.length,
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final art = state.artPieces[index];

                              return ArtCard(
                                artwork: art,
                                isGuest: isGuest,
                                onActionPressed: () async {
                                  if (isGuest) {
                                    _goToSignup(
                                      context,
                                    );
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
                  ),
                ],
              ),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const Center(
            child: Text(
              'Start exploring art!',
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(
    ThemeData theme,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
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
            hintText: 'Search art, artists, categories...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.tune,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
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
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (
          context,
          index,
        ) {
          final categoryName = categories[index];

          final isSelected = categoryName == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary
              : theme.colorScheme.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onSecondary
                  : theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
