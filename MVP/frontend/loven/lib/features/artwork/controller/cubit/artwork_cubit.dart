import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/artwork/data/repositories/artwork_repository.dart';
import 'artwork_state.dart';

class ArtworkCubit extends Cubit<ArtworkState> {
  final ArtworkRepository _repository;

  ArtworkCubit(this._repository) : super(ArtworkInitial());

  Future<void> listPublicArtworks({
    int limit = 20,
    int offset = 0,
    String status = 'available',
  }) async {
    emit(ArtworkLoading());

    try {
      final data = await _repository.listPublicArtworks(
        limit: limit,
        offset: offset,
        status: status,
      );

      emit(ArtworksLoaded(data['artworks'] ?? data['data'] ?? []));
    } catch (e) {
      emit(ArtworkError(e.toString()));
    }
  }

  Future<void> searchArtworks({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    emit(ArtworkLoading());

    try {
      final data = await _repository.searchArtworks(
        query: query,
        limit: limit,
        offset: offset,
      );

      emit(ArtworksLoaded(data['artworks'] ?? data['data'] ?? []));
    } catch (e) {
      emit(ArtworkError(e.toString()));
    }
  }

  Future<void> listMyArtworks({
    int limit = 20,
    int offset = 0,
  }) async {
    emit(ArtworkLoading());

    try {
      final data = await _repository.listMyArtworks(
        limit: limit,
        offset: offset,
      );

      emit(ArtworksLoaded(data['artworks'] ?? data['data'] ?? []));
    } catch (e) {
      emit(ArtworkError(e.toString()));
    }
  }

  Future<void> getArtwork({
    required String artworkId,
  }) async {
    emit(ArtworkLoading());

    try {
      final artwork = await _repository.getArtwork(
        artworkId: artworkId,
      );

      emit(ArtworkLoaded(artwork));
    } catch (e) {
      emit(ArtworkError(e.toString()));
    }
  }
  
  Future<void> createArtwork({
    required String title,
    required String description,
    required double price,
    required int quantityAvailable,
    required double shippingFee,
    required String artworkImageUrl,
    }) async {
      emit(ArtworkLoading());
      
      try {
        final artwork = await _repository.createArtwork(
          title: title,
          description: description,
          price: price,
          quantityAvailable: quantityAvailable,
          shippingFee: shippingFee,
          artworkImageUrl: artworkImageUrl,
        );
        
        emit(ArtworkLoaded(artwork));
        } catch (e) {
          emit(ArtworkError(e.toString()));
        }
      }

  Future<void> updateArtwork({
    required String artworkId,
    String? title,
    String? description,
    double? price,
    int? quantityAvailable,
    double? shippingFee,
    String? artworkImageUrl,
    String? status,
  }) async {
    emit(ArtworkLoading());
    
    try {
      final artwork = await _repository.updateArtwork(
        artworkId: artworkId,
        title: title,
        description: description,
        price: price,
        quantityAvailable: quantityAvailable,
        shippingFee: shippingFee,
        artworkImageUrl: artworkImageUrl,
        status: status,
      );
      
      emit(ArtworkLoaded(artwork));
      } catch (e) {
        emit(ArtworkError(e.toString()));
      }
    }

  Future<void> deleteArtwork({
    required String artworkId,
  }) async {
    emit(ArtworkLoading());

    try {
      await _repository.deleteArtwork(
        artworkId: artworkId,
      );

      emit(ArtworkSuccess('Artwork deleted successfully'));
    } catch (e) {
      emit(ArtworkError(e.toString()));
    }
  }
}
