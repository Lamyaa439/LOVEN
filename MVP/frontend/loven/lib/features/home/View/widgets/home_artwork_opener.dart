import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/art_details_screen.dart';

void openHomeArtwork(BuildContext context, ArtworkModel artwork) {
  final repository = context.read<ArtistRepository>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.92,
        child: ArtDetailsScreen(
          artItem: artwork,
          artistRepository: repository,
        ),
      );
    },
  );
}
