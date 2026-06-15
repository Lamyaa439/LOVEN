import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artwork/view/widgets/artwork_grid_widget.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/home/controller/bloc/home_state.dart';

class ArtworksListScreen extends StatelessWidget {
  const ArtworksListScreen({
    super.key,
    required this.type,
  });

  final String type;

  String get title {
    if (type == 'new-arrivals') {
      return 'New Arrivals';
    }

    return 'Featured Artworks';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return GalleryLoadingState(
              message: 'Loading $title…',
            );
          }

          if (state is HomeError) {
            return GalleryEmptyState(
                backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.error_outline,
              title: 'Could not load artworks',
              subtitle: state.message,
              actionLabel: 'Try again',
              onAction: () {
                context.read<HomeBloc>().add(FetchHomeData());
              },
            );
          }

          if (state is! HomeLoaded) {
            return GalleryEmptyState(
                backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.palette_outlined,
              title: 'No artworks found',
              subtitle: 'Check back soon for new works.',
            );
          }

          final artworks = type == 'new-arrivals'
              ? state.allArtworks.skip(1).toList()
              : state.allArtworks;

          if (artworks.isEmpty) {
            return GalleryEmptyState(
                backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.palette_outlined,
              title: 'No artworks found',
              subtitle: 'New pieces will appear here as artists publish.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.lg,
              AppSpacing.screenPadding,
              AppSpacing.bottomNavClearance,
            ),
            child: ArtworkGridWidget(
              artworks: artworks,
              canManage: false,
            ),
          );
        },
      ),
    );
  }
}
