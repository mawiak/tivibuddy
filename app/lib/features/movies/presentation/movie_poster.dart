import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vod/presentation/poster_tile.dart';
import '../application/movie_providers.dart';
import '../domain/movie.dart';

/// A movie in the grid with the progress, watched state and favorite of
/// the active profile. [movie] is null while its page loads.
class MoviePoster extends ConsumerWidget {
  const MoviePoster({
    super.key,
    required this.movie,
    required this.onSelect,
    this.onFocusChange,
    this.autofocus = false,
  });

  final Movie? movie;
  final VoidCallback? onSelect;
  final void Function(bool focused, BuildContext context)? onFocusChange;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = this.movie;
    final state = movie == null
        ? MovieState.initial
        : ref.watch(movieStateProvider(movie)).value ?? MovieState.initial;
    return PosterTile(
      title: movie?.name ?? '',
      posterUrl: movie?.posterUrl,
      onSelect: onSelect,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      progress: state.canResume ? state.progress : null,
      watched: state.watched,
      favorite: state.favorite,
    );
  }
}
