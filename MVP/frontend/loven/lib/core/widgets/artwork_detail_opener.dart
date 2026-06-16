import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/home/View/widgets/art_details_screen.dart';

const _sheetTopRadius = Radius.circular(AppRadius.xl);

/// Opens artwork detail as a bottom sheet — single entry point for browse surfaces.
void openArtworkDetail(BuildContext context, ArtworkModel artwork) {
  final repository = context.read<ArtistRepository>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: _sheetTopRadius),
    ),
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.92,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: _sheetTopRadius),
          child: ArtDetailsScreen(
            artItem: artwork,
            artistRepository: repository,
          ),
        ),
      );
    },
  );
}
