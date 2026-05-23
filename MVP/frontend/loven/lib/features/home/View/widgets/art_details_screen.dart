import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/artist_profile/model/artist_repository.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';

class ArtDetailsScreen extends StatefulWidget {
  final ArtworkModel artItem;

  const ArtDetailsScreen({
    super.key,
    required this.artItem,
  });

  @override
  State<ArtDetailsScreen> createState() => _ArtDetailsScreenState();
}

class _ArtDetailsScreenState extends State<ArtDetailsScreen> {
  bool _checkingOwner = true;
  bool _isOwnArtwork = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _checkIfOwnArtwork();
  }

  Future<void> _checkIfOwnArtwork() async {
    try {
      final artist = await ArtistRepository().getMyProfile();

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
    if (_isOwnArtwork) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You cannot buy your own artwork',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    await context.read<CartCubit>().addItem(
          artworkId: widget.artItem.id,
          quantity: 1,
        );

    if (!mounted) return;

    setState(() {
      _isAddingToCart = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Artwork added to cart',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final isOutOfStock = (widget.artItem.quantityAvailable ?? 0) <= 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
        title: Text(
          'Details',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black54 : Colors.black12,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Hero(
                    tag: widget.artItem.id,
                    child: Image.network(
                      widget.artItem.artworkImageUrl ?? '',
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          height: 400,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.artItem.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),

                      Text(
                        '${widget.artItem.price ?? 0} SAR',
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available: ${widget.artItem.quantityAvailable ?? 0}',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: AppColors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Shipping Fee: ${widget.artItem.shippingFee ?? 0} SAR',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  Divider(
                    height: 40,
                    color: theme.dividerColor,
                  ),

                  Text(
                    'About this piece',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.artItem.description ?? 'No description provided.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _checkingOwner ||
                              _isAddingToCart ||
                              _isOwnArtwork ||
                              isOutOfStock
                          ? null
                          : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
                                        : 'Add to Cart',
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}