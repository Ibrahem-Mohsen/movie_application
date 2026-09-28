import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_lists_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_poster.dart';
import '../widgets/state_views.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late final Future<Movie> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = context.read<MovieProvider>().getDetails(widget.movie.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final user = context.read<AuthProvider>().currentUser!;
        context.read<MovieListsProvider>().loadMovieStatus(
          user.uid,
          widget.movie.id,
        );
      }
    });
  }

  Future<void> _toggle(Movie movie, MovieListType type) async {
    final user = context.read<AuthProvider>().currentUser!;
    try {
      await context.read<MovieListsProvider>().toggleMovie(
        user.uid,
        movie,
        type,
      );
    } catch (_) {
      if (!mounted) return;
      final message = context.read<MovieListsProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Could not update your list. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Movie>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final movie = snapshot.data ?? widget.movie;
        return Scaffold(
          appBar: AppBar(title: const Text('Movie details')),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(
                  child: LoadingView(message: 'Loading movie details...'),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (movie.backdropPath?.isNotEmpty == true)
                            SizedBox(
                              height: 210,
                              width: double.infinity,
                              child: MoviePoster(
                                posterPath: movie.backdropPath,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 14,
                                  runSpacing: 8,
                                  children: [
                                    _InfoLabel(
                                      icon: Icons.star_rounded,
                                      text: movie.voteAverage.toStringAsFixed(
                                        1,
                                      ),
                                      color: const Color(0xFFFFC857),
                                    ),
                                    if (movie.releaseDate?.isNotEmpty == true)
                                      _InfoLabel(
                                        icon: Icons.calendar_month_outlined,
                                        text: movie.releaseDate!,
                                      ),
                                    if (movie.runtime != null)
                                      _InfoLabel(
                                        icon: Icons.schedule,
                                        text: '${movie.runtime} min',
                                      ),
                                  ],
                                ),
                                if (movie.genres.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    movie.genres.join('  •  '),
                                    style: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 22),
                                Text(
                                  'Overview',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  movie.overview.isEmpty
                                      ? 'No overview is available for this movie.'
                                      : movie.overview,
                                ),
                                if (snapshot.hasError) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Some details could not be loaded. ${snapshot.error}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                Text(
                                  'Your lists',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                ...MovieListType.values.map(
                                  (type) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _ListAction(
                                      movieId: movie.id,
                                      type: type,
                                      onPressed: () => _toggle(movie, type),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ListAction extends StatelessWidget {
  const _ListAction({
    required this.movieId,
    required this.type,
    required this.onPressed,
  });

  final int movieId;
  final MovieListType type;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListsProvider>(
      builder: (context, lists, child) {
        final saved = lists.isInList(movieId, type);
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(saved ? Icons.check_circle : Icons.add_circle_outline),
          label: Text(saved ? 'In ${type.title}' : 'Add to ${type.title}'),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size.fromHeight(48),
          ),
        );
      },
    );
  }
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17, color: color ?? Colors.white60),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(color: Colors.white70)),
    ],
  );
}
