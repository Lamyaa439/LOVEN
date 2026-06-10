/// Fixed component sizes — use with spacing/radius tokens, not instead of them.
class AppSizes {
  AppSizes._();

  static const double buttonHeight = 48;
  static const double buttonHeightCompact = 40;
  static const double inputHeight = 48;
  static const double touchTargetMin = 44;

  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;

  static const double avatarSm = 36;
  static const double avatarMd = 48;
  static const double avatarLg = 64;
  static const double avatarXl = 80;

  /// Standard horizontal artwork card width (browse rails).
  static const double artworkCardWidth = 180;

  /// Target image height for gallery browse cards (3:4 feel).
  static const double artworkCardImageHeight = 240;

  /// Total browse card height (image + metadata block).
  static const double artworkCardTotalHeight = 340;

  /// Collection list row thumbnail.
  static const double collectionThumbSize = 80;

  /// Artist strip card dimensions.
  static const double artistStripHeight = 96;
  static const double artistStripCardWidth = 240;

  /// Featured exhibition hero on Home.
  static const double featuredHeroHeight = 420;

  /// Horizontal artwork rail total height (card + spacing).
  static const double artworkRailHeight = 360;

  /// DailyArt-style horizontal masterpiece tile.
  static const double showcaseTileWidth = 150;
  static const double showcaseTileHeight = 210;

  /// Square thumbnail in vertical list rows.
  static const double listThumbSize = 72;

  /// Width of artist row in horizontal section.
  static const double artistRowWidth = 220;

  /// Content panel overlap above hero bottom edge.
  static const double heroContentOverlap = 28;

  /// Discover hero carousel card height (landscape).
  static const double discoverHeroHeight = 220;

  /// Discover horizontal rail card.
  static const double discoverRailCardWidth = 136;
  static const double discoverRailCardHeight = 200;

  /// Discover masterpieces mosaic block height.
  static const double discoverMosaicHeight = 300;

  /// DailyArt Discover — featured landscape card.
  static const double discoverFeaturedHeight = 200;

  /// DailyArt Discover — genre grid cell height.
  static const double discoverGenreHeight = 168;

  /// DailyArt Discover — best-match large tile.
  static const double discoverBestMatchLargeHeight = 280;

  /// DailyArt Discover — best-match small tile.
  static const double discoverBestMatchSmallHeight = 134;

  /// DailyArt Discover — masterpiece grid cell.
  static const double discoverGridTileHeight = 160;

  static const double bottomNavHeight = 64;
  static const double appBarHeight = 56;

  /// Logo height in shell [AppBar] (non-Home tabs).
  static const double shellLogoHeight = 40;

  /// Floating [NavigationWidget] dimensions.
  static const double floatingNavStackHeight = 82;
  static const double floatingNavBarHeight = 58;
  static const double floatingNavFabSize = 58;
  static const double floatingNavFabBorderWidth = 5;
  static const double floatingNavHorizontalGutter = 20;
  static const double floatingNavBottomInset = 24;

  /// Bottom padding for tab bodies so content clears [NavigationWidget].
  static const double shellFloatingNavClearance =
      floatingNavStackHeight + floatingNavBottomInset;
  static const double floatingNavArtistSlotWidth = 64;
  static const double floatingNavIconSize = 25;
  static const double floatingNavFabIconSize = 32;
  static const double cartBadgeMinSize = 18;
  static const double cartBadgeFontSize = 10;

  static const double mobileMaxContentWidth = 480;
  static const double tabletMaxContentWidth = 720;
  static const double desktopMaxContentWidth = 1000;
}
