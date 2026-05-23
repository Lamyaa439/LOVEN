abstract class HomeEvent {}

class FetchHomeData extends HomeEvent {}

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
