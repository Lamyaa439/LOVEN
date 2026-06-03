import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';

class ArtistPortfolioPreviewGrid extends StatelessWidget {
  const ArtistPortfolioPreviewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _PortfolioItem(
        title: 'Lavender Memory',
        price: 'SAR 450',
        sold: false,
        variant: 0,
      ),
      const _PortfolioItem(
        title: 'Blue Horizon',
        price: 'SAR 320',
        sold: false,
        variant: 1,
      ),
      const _PortfolioItem(
        title: 'Soft Bloom',
        price: 'SAR 280',
        sold: false,
        variant: 2,
      ),
      const _PortfolioItem(
        title: 'Dreamscape',
        price: 'Sold',
        sold: true,
        variant: 3,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return PressableCard(
            onTap: () {},
            child: _PortfolioCard(
              item: items[index],
            ),
          );
        },
      ),
    );
  }
}

class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _pressed ? 0.025 : 0.045,
                ),
                blurRadius: _pressed ? 8 : 16,
                offset: Offset(
                  0,
                  _pressed ? 4 : 8,
                ),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({
    required this.item,
  });

  final _PortfolioItem item;

  @override
  Widget build(BuildContext context) {
    final priceColor = item.sold ? Colors.red.shade400 : AppColors.primaryBlue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'portfolio-${item.title}',
              child: _MockArtwork(
                variant: item.variant,
                sold: item.sold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.price,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: priceColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockArtwork extends StatelessWidget {
  const _MockArtwork({
    required this.variant,
    required this.sold,
  });

  final int variant;
  final bool sold;

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [
        AppColors.primaryPurple.withValues(alpha: 0.95),
        AppColors.deepPurple.withValues(alpha: 0.78),
        AppColors.primaryBlue.withValues(alpha: 0.78),
      ],
      [
        const Color(0xFFEDE7F6),
        const Color(0xFFB9A7EA),
        const Color(0xFF293CAE),
      ],
      [
        const Color(0xFFFFF4F7),
        AppColors.primaryPurple,
        const Color(0xFFE7A7C8),
      ],
      [
        const Color(0xFFEEF2FF),
        const Color(0xFFBFD7FF),
        AppColors.primaryBlue,
      ],
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradients[variant % gradients.length],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -18,
            child: _BlurCircle(
              size: 104,
              opacity: 0.16,
            ),
          ),
          Positioned(
            bottom: -34,
            left: -26,
            child: _BlurCircle(
              size: 130,
              opacity: 0.11,
            ),
          ),
          Positioned(
            top: 32,
            left: 18,
            child: _SoftShape(
              width: 52,
              height: 86,
              opacity: 0.15,
              radius: 28,
            ),
          ),
          Positioned(
            bottom: 34,
            right: 20,
            child: _SoftShape(
              width: 78,
              height: 42,
              opacity: 0.18,
              radius: 24,
            ),
          ),
          Center(
            child: Icon(
              variant.isEven
                  ? Icons.auto_awesome_rounded
                  : Icons.palette_outlined,
              size: 38,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          if (sold)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'SOLD',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.4,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SoftShape extends StatelessWidget {
  const _SoftShape({
    required this.width,
    required this.height,
    required this.opacity,
    required this.radius,
  });

  final double width;
  final double height;
  final double opacity;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _PortfolioItem {
  const _PortfolioItem({
    required this.title,
    required this.price,
    required this.sold,
    required this.variant,
  });

  final String title;
  final String price;
  final bool sold;
  final int variant;
}