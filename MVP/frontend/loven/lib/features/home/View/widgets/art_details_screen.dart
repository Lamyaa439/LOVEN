import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/session/app_session.dart';

import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_cubit.dart';
import 'package:loven/features/favorites/controller/cubit/favorites_state.dart';

class ArtDetailsScreen extends StatefulWidget {
  final ArtworkModel artItem;
  final ArtistRepository artistRepository;

  const ArtDetailsScreen({
    super.key,
    required this.artItem,
    required this.artistRepository,
  });

  @override
  State<ArtDetailsScreen> createState() => _ArtDetailsScreenState();
}

class _ArtDetailsScreenState extends State<ArtDetailsScreen> {
  bool _checkingOwner = true;
  bool _isOwnArtwork = false;
  bool _isAddingToCart = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _checkIfOwnArtwork();
  }

  Future<void> _checkIfOwnArtwork() async {
    if (!AppSession.hasSessionFromContext(context)) {
      setState(() {
        _isOwnArtwork = false;
        _checkingOwner = false;
      });
      return;
    }

    try {
      final artistRepository = context.read<ArtistRepository>();
      final artist = await artistRepository.getMyProfile();

      if (!mounted) return;

      setState(() {
        _isOwnArtwork = artist.id == widget.artItem.artistProfileId;
        _checkingOwner = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isOwnArtwork = false;
        _checkingOwner = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (!AppSession.hasSessionFromContext(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in or sign up to add items to cart.'),
        ),
      );

      context.go(AppRoutes.auth);
      return;
    }

    final stock = widget.artItem.quantityAvailable ?? 0;

    if (_isOwnArtwork) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot buy your own artwork'),
        ),
      );
      return;
    }

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This artwork is out of stock'),
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await context.read<CartCubit>().addItem(
            artworkId: widget.artItem.id,
            quantity: _quantity,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.artItem.title} added to cart'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not add item to cart.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _increaseQuantity() {
    final stock = widget.artItem.quantityAvailable ?? 0;

    if (_quantity >= stock) return;

    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity <= 1) return;

    setState(() {
      _quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = (widget.artItem.quantityAvailable ?? 0) <= 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHandle(theme),
              const SizedBox(height: 16),
              _buildImage(theme),
              const SizedBox(height: 22),
              _buildTitleRow(theme),
              const SizedBox(height: 8),
              _buildArtistRow(theme),
              const SizedBox(height: 16),
              _buildDescription(theme),
              const SizedBox(height: 24),
              _buildArtworkInfo(theme),
              const SizedBox(height: 24),
              _buildQuantityAndPrice(theme),
              const SizedBox(height: 28),
              _buildBottomActions(
                theme: theme,
                isOutOfStock: isOutOfStock,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHandle(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        const Spacer(),
        Container(
          width: 52,
          height: 5,
          decoration: BoxDecoration(
            color: theme.dividerColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildImage(ThemeData theme) {
    final imageUrl = widget.artItem.artworkImageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 70,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          imageUrl,
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 320,
              width: double.infinity,
              color: theme.colorScheme.surface,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 70,
                color: theme.colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleRow(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.artItem.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final favoriteIds = state is FavoritesLoaded
                ? state.favoriteArtworkIds
                : <String>{};

            final isFavorited = favoriteIds.contains(widget.artItem.id);

            return IconButton(
              onPressed: () {
                if (!AppSession.hasSessionFromContext(context)) {
                  Navigator.pop(context);
                  context.push(AppRoutes.auth);
                  return;
                }

                context.read<FavoritesCubit>().toggleFavorite(
                      widget.artItem.id,
                    );
              },
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: theme.colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildArtistRow(ThemeData theme) {
    return Row(
      children: [
        Text(
          widget.artItem.artistDisplayName ?? 'Artist',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (widget.artItem.artistIsVerified) ...[
          const SizedBox(width: 5),
          Icon(
            Icons.verified_rounded,
            size: 17,
            color: theme.colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      widget.artItem.description ?? 'No description provided.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
        height: 1.45,
      ),
    );
  }

  Widget _buildArtworkInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artwork Info',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Available: ${widget.artItem.quantityAvailable ?? 0}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Shipping: ${widget.artItem.shippingFee ?? 0} SAR',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityAndPrice(ThemeData theme) {
    return Row(
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _decreaseQuantity,
                icon: Icon(
                  Icons.remove_circle,
                  color: theme.disabledColor,
                ),
              ),
              Text(
                '$_quantity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: _increaseQuantity,
                icon: Icon(
                  Icons.add_circle,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Text(
          '${widget.artItem.price ?? 0} SAR',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions({
    required ThemeData theme,
    required bool isOutOfStock,
  }) {
    final disabled =
        _checkingOwner || _isAddingToCart || _isOwnArtwork || isOutOfStock;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: disabled ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              _checkingOwner
                  ? 'Checking...'
                  : _isAddingToCart
                      ? 'Adding...'
                      : _isOwnArtwork
                          ? 'Your Artwork'
                          : isOutOfStock
                              ? 'Out of Stock'
                              : 'Add to cart',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.cart);
            },
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'View cart',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
