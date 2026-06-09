import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/home_artwork_opener.dart';

/// Featured hero carousel — large landscape card, pill tag, serif title, dots.
class HomeDiscoverHero extends StatefulWidget {
  const HomeDiscoverHero({
    super.key,
    required this.artworks,
  });

  final List<ArtworkModel> artworks;

  @override
  State<HomeDiscoverHero> createState() => _HomeDiscoverHeroState();
}

class _HomeDiscoverHeroState extends State<HomeDiscoverHero> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artworks.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final items = widget.artworks.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          SizedBox(
            height: AppSizes.discoverHeroHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final art = items[index];
                return _HeroSlide(artwork: art, theme: theme);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _PageDots(count: items.length, current: _currentPage),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({
    required this.artwork,
    required this.theme,
  });

  final ArtworkModel artwork;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final imageUrl = artwork.artworkImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openHomeArtwork(context, artwork),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _HeroFallback(),
                )
              else
                const _HeroFallback(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.heroBottomGradient,
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                top: AppSpacing.lg,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scrim.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'COLLECTION',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnBrand,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Text(
                  artwork.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.textOnBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceSoft,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: AppSizes.iconLg,
          color: AppColors.favoriteEmpty,
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: isActive ? AppSpacing.sm : AppSpacing.xs,
          height: AppSpacing.xs,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }
}
