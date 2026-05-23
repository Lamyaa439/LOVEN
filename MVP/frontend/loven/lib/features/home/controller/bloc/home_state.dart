import 'package:loven/features/artist_profile/model/artist_model.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ArtworkModel> allArtworks;
  final List<ArtworkModel> artPieces;
  final List<String> categories;

  final String selectedCategory;
  final String searchQuery;

  HomeLoaded({
    required this.allArtworks,
    required this.categories,
    required this.artPieces,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  HomeLoaded copyWith({
    List<ArtworkModel>? allArtworks,
    List<ArtworkModel>? artPieces,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return HomeLoaded(
      allArtworks:
          allArtworks ?? this.allArtworks,
      artPieces:
          artPieces ?? this.artPieces,
      categories:
          categories ?? this.categories,
      selectedCategory:
          selectedCategory ??
              this.selectedCategory,
      searchQuery:
          searchQuery ?? this.searchQuery,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}