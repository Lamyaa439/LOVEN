import 'package:flutter/material.dart';
import 'package:loven/core/widgets/artwork_detail_opener.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';

/// Home browse alias — delegates to [openArtworkDetail].
void openHomeArtwork(BuildContext context, ArtworkModel artwork) {
  openArtworkDetail(context, artwork);
}
