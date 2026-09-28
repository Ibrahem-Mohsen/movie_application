import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/state_views.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openMovie(BuildContext context, Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        final hasMovies = provider.moviesBySection.values.any(
          (list) => list.isNotEmpty,
        );
        if (provider.isLoadingHome && !hasMovies) {
          return const Center(child: LoadingView(message: 'Finding movies...'));
        }

        if (!hasMovies && provider.sectionErrors.isNotEmpty) {
          return ErrorView(
            message: provider.sectionErrors.values.first,
            onRetry: provider.loadHome,
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MoviesApp',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Find your next favorite movie.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ),
              for (final section in MovieProvider.sections.keys)
                _MovieSection(
                  title: section,
                  movies: provider.moviesBySection[section] ?? const [],
                  error: provider.sectionErrors[section],
                  onMovieTap: (movie) => _openMovie(context, movie),
                  onRetry: provider.loadHome,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        );
      },
    );
  }
}

class _MovieSection extends StatelessWidget {
  const _MovieSection({
    required this.title,
    required this.movies,
    required this.error,
    required this.onMovieTap,
    required this.onRetry,
  });

  final String title;
  final List<Movie> movies;
  final String? error;
  final ValueChanged<Movie> onMovieTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty && error == null) return const SliverToBoxAdapter();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (error != null)
                    IconButton(
                      tooltip: 'Try again',
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 20),
                    ),
                ],
              ),
            ),
            if (error != null && movies.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.white60),
                ),
              )
            else
              SizedBox(
                height: 310,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => MovieCard(
                    movie: movies[index],
                    onTap: () => onMovieTap(movies[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
