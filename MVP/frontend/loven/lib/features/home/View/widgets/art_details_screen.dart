import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/session/app_session.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/cart/controller/cubit/cart_cubit.dart';
import 'package:loven/features/report/controller/cubit/report_cubit.dart';

/// Editorial artwork detail surface — opened via [openArtworkDetail].
class ArtDetailsScreen extends StatefulWidget {
  const ArtDetailsScreen({
    super.key,
    required this.artItem,
    required this.artistRepository,
  });

  final ArtworkModel artItem;
  final ArtistRepository artistRepository;

  @override
  State<ArtDetailsScreen> createState() => _ArtDetailsScreenState();
}

class _ArtDetailsScreenState extends State<ArtDetailsScreen> {
  late ArtworkModel _artwork;
  bool _checkingOwner = true;
  bool _isOwnArtwork = false;
  bool _isAddingToCart = false;
  bool _refreshingArtwork = true;
  int _quantity = 1;

  bool get _isSoldOut {
    final status = _artwork.status?.toLowerCase();
    if (status == 'sold_out') {
      return true;
    }

    return (_artwork.quantityAvailable ?? 0) <= 0;
  }

  String get _availabilityLabel {
    if (_isSoldOut) {
      return 'Availability · Sold out';
    }

    return 'Available · ${_artwork.quantityAvailable ?? 0}';
  }

  @override
  void initState() {
    super.initState();
    _artwork = widget.artItem;
    _refreshArtwork();
    _checkIfOwnArtwork();
  }

  Future<void> _refreshArtwork() async {
    try {
      final fresh = await widget.artistRepository.getArtworkById(_artwork.id);

      if (!mounted) return;

      setState(() {
        _artwork = fresh;
        _refreshingArtwork = false;
        if (_quantity > (_artwork.quantityAvailable ?? 0) &&
            (_artwork.quantityAvailable ?? 0) > 0) {
          _quantity = _artwork.quantityAvailable ?? 1;
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _refreshingArtwork = false;
      });
    }
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
        _isOwnArtwork = artist.id == _artwork.artistProfileId;
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

  Future<void> _showReportDialog() async {
    if (!AppSession.hasSessionFromContext(context)) {
      context.go(AppRoutes.auth);
      return;
    }

    String selectedReason = 'Copyright infringement';
    final detailsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Report artwork'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Copyright infringement',
                        child: Text('Copyright infringement'),
                      ),
                      DropdownMenuItem(
                        value: 'Offensive content',
                        child: Text('Offensive content'),
                      ),
                      DropdownMenuItem(
                        value: 'Spam',
                        child: Text('Spam'),
                      ),
                      DropdownMenuItem(
                        value: 'Fake artwork',
                        child: Text('Fake artwork'),
                      ),
                      DropdownMenuItem(
                        value: 'Misleading description',
                        child: Text('Misleading description'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedReason = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Additional details (optional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final success =
                          await context.read<ReportCubit>().submitReport(
                                targetType: 'artwork',
                                targetId: _artwork.id,
                                reason: selectedReason,
                                details: detailsController.text.trim().isEmpty
                                    ? null
                                    : detailsController.text.trim(),
                              );

                      if (!context.mounted) return;

                      Navigator.pop(dialogContext);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report submitted'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to submit report'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to submit report'),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
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

    if (_isOwnArtwork) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot buy your own artwork'),
        ),
      );
      return;
    }

    if (_isSoldOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This artwork is sold out'),
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await context.read<CartCubit>().addItem(
            artworkId: _artwork.id,
            quantity: _quantity,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_artwork.title} added to cart'),
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
    final stock = _artwork.quantityAvailable ?? 0;

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

  String _formatShippingLabel(double? fee) {
    if (fee == null) {
      return 'Shipping · Not specified';
    }
    return 'Shipping · ${fee.toStringAsFixed(0)} SAR';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = _isSoldOut;
    final disabled = _checkingOwner ||
        _refreshingArtwork ||
        _isAddingToCart ||
        _isOwnArtwork ||
        isOutOfStock;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _SheetHeader(
              artworkId: _artwork.id,
              onClose: () => Navigator.pop(context),
              onReport: _showReportDialog,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.none,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ArtworkHeroImage(imageUrl: _artwork.artworkImageUrl),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _artwork.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ArtistLine(artwork: _artwork),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _artwork.description?.trim().isNotEmpty == true
                          ? _artwork.description!.trim()
                          : 'No description provided.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: AppColors.textSecondary,
                        fontStyle: _artwork.description?.trim().isNotEmpty ==
                                true
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    Text(
                      'Details',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: _availabilityLabel,
                      highlightSoldOut: isOutOfStock,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(
                      icon: Icons.local_shipping_outlined,
                      label: _formatShippingLabel(_artwork.shippingFee),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                formatArtworkPrice(_artwork.price),
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        if (!isOutOfStock)
                          _QuantityStepper(
                            quantity: _quantity,
                            onDecrease: _decreaseQuantity,
                            onIncrease: _increaseQuantity,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _BottomActions(
              checkingOwner: _checkingOwner || _refreshingArtwork,
              isAddingToCart: _isAddingToCart,
              isOwnArtwork: _isOwnArtwork,
              isOutOfStock: isOutOfStock,
              disabled: disabled,
              onAddToCart: _addToCart,
              onViewCart: () {
                Navigator.pop(context);
                context.go(AppRoutes.cart);
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.artworkId,
    required this.onClose,
    required this.onReport,
  });

  final String artworkId;
  final VoidCallback onClose;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.none,
      ),
      child: SizedBox(
        height: AppSizes.touchTargetMin,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Container(
                width: AppSizes.cartBadgeMinSize * 2,
                height: AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface,
                    size: AppSizes.iconMd,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onReport,
                  tooltip: 'Report artwork',
                  icon: Icon(
                    Icons.flag_outlined,
                    color: AppColors.textMuted,
                    size: AppSizes.iconMd,
                  ),
                ),
                LovenArtworkFavoriteButton(artworkId: artworkId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkHeroImage extends StatelessWidget {
  const _ArtworkHeroImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: LovenArtworkImage(imageUrl: imageUrl),
      ),
    );
  }
}

class _ArtistLine extends StatelessWidget {
  const _ArtistLine({required this.artwork});

  final ArtworkModel artwork;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          artwork.artistDisplayName ?? 'Artist',
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (artwork.artistIsVerified) ...[
          const SizedBox(width: AppSpacing.xxs),
          Icon(
            Icons.verified_rounded,
            size: AppSizes.iconSm,
            color: AppColors.brandPrimary,
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.highlightSoldOut = false,
  });

  final IconData icon;
  final String label;
  final bool highlightSoldOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.iconSm,
          color: highlightSoldOut ? AppColors.error : AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: highlightSoldOut
                  ? AppColors.error
                  : AppColors.textSecondary,
              fontWeight:
                  highlightSoldOut ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrease,
            icon: Icon(
              Icons.remove,
              size: AppSizes.iconSm,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            '$quantity',
            style: theme.textTheme.titleSmall,
          ),
          IconButton(
            onPressed: onIncrease,
            icon: Icon(
              Icons.add,
              size: AppSizes.iconSm,
              color: AppColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.checkingOwner,
    required this.isAddingToCart,
    required this.isOwnArtwork,
    required this.isOutOfStock,
    required this.disabled,
    required this.onAddToCart,
    required this.onViewCart,
  });

  final bool checkingOwner;
  final bool isAddingToCart;
  final bool isOwnArtwork;
  final bool isOutOfStock;
  final bool disabled;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;

  String get _primaryLabel {
    if (checkingOwner) return 'Checking…';
    if (isAddingToCart) return 'Adding…';
    if (isOwnArtwork) return 'Your artwork';
    if (isOutOfStock) return 'Sold out';
    return 'Add to cart';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: LovenPrimaryButton(
              label: _primaryLabel,
              isLoading: isAddingToCart,
              onPressed: disabled ? null : onAddToCart,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: LovenSecondaryButton(
              label: 'View cart',
              expand: true,
              onPressed: onViewCart,
            ),
          ),
        ],
      ),
    );
  }
}
