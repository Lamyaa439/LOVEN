import 'package:flutter/material.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/artist_profile/view/screens/artist_profile_screen.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../mocks/preview_cubits.dart';
import '../mocks/preview_repositories.dart';
import '../mocks/preview_shell.dart';

@widgetbook.UseCase(name: 'Loading', type: ArtistProfileScreen)
Widget artistProfileLoadingUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(AuthSuccess(user: null)),
    artworkCubit: PreviewArtworkCubit(),
    child: ArtistProfileScreen(
      repository: PreviewArtistRepository(
        loadingDelay: const Duration(seconds: 30),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Success', type: ArtistProfileScreen)
Widget artistProfileSuccessUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(AuthSuccess(user: null)),
    artworkCubit: PreviewArtworkCubit(),
    child: ArtistProfileScreen(
      repository: PreviewArtistRepository(),
    ),
  );
}

@widgetbook.UseCase(name: 'Error', type: ArtistProfileScreen)
Widget artistProfileErrorUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(AuthSuccess(user: null)),
    artworkCubit: PreviewArtworkCubit(),
    child: ArtistProfileScreen(
      repository: PreviewArtistRepository(failOnFetch: true),
    ),
  );
}

@widgetbook.UseCase(name: 'Public profile', type: ArtistProfileScreen)
Widget artistProfilePublicUseCase(BuildContext context) {
  return previewShell(
    authCubit: PreviewAuthCubit(AuthGuest()),
    artworkCubit: PreviewArtworkCubit(),
    child: ArtistProfileScreen(
      repository: PreviewArtistRepository(),
      artistProfileId: 'artist-profile-1',
    ),
  );
}
