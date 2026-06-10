abstract class HomeEvent {}

class FetchHomeData extends HomeEvent {
  FetchHomeData({this.silent = false});

  /// When true, keep the current gallery visible while refetching in the
  /// background (used when returning to the Home tab).
  final bool silent;
}

class FilterArtworks extends HomeEvent {
  final String? searchText;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final bool? showWorkshops;

  FilterArtworks({
    this.searchText,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.showWorkshops,
  });
}
