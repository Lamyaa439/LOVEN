import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_state.dart';
import 'package:loven/features/artwork/view/widgets/artwork_grid_widget.dart';

class ArtworksListScreen extends StatelessWidget {
  final String type;

  const ArtworksListScreen({
    super.key,
    required this.type,
  });

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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HomeError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is! HomeLoaded) {
            return const Center(
              child: Text('No artworks found.'),
            );
          }

          final artworks = type == 'new-arrivals'
              ? state.allArtworks.skip(1).toList()
              : state.allArtworks;

          if (artworks.isEmpty) {
            return const Center(
              child: Text('No artworks found.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 32,
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