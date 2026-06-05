import 'package:loven/features/artist_profile/data/artist_repository.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/verification_request/data/repositories/verification_request_repository.dart';

/// Dependencies shared by route builders in [buildAppRouteList].
///
/// Injected once from [AppRouter] / [LovenApp] startup — route modules must not
/// construct repositories or cubits that belong in composition root.
class AppRouterDeps {
  const AppRouterDeps({
    required this.authCubit,
    required this.artistRepository,
    required this.verificationRequestRepository,
  });

  final AuthCubit authCubit;
  final ArtistRepository artistRepository;
  final VerificationRequestRepository verificationRequestRepository;
}
