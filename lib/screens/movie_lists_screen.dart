import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../providers/movie_lists_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/state_views.dart';
import 'movie_details_screen.dart';

class MovieListsScreen extends StatefulWidget {
  const MovieListsScreen({super.key, required this.user});

  final User user;

  @override
  State<MovieListsScreen> createState() => _MovieListsScreenState();
}

class _MovieListsScreenState extends State<MovieListsScreen> {
  MovieListType _selectedType = MovieListType.favorite;

  void _openMovie(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieListsProvider>(
      builder: (context, provider, child) {
        final movies = provider.movies[_selectedType] ?? const <Movie>[];
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My lists',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedType.description,
                      style: const TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: MovieListType.values.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(type.title),
                              selected: _selectedType == type,
                              onSelected: (_) =>
                                  setState(() => _selectedType = type),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.isLoading && movies.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingView(message: 'Loading your lists...'),
              )
            else if (provider.errorMessage != null && movies.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  message: provider.errorMessage!,
                  onRetry: () => provider.loadAll(widget.user.uid),
                ),
              )
            else if (movies.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  title: 'No ${_selectedType.title.toLowerCase()} yet',
                  message: 'Open a movie and add it to this list.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid.builder(
                  itemCount: movies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.53,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) => MovieCard(
                    width: double.infinity,
                    movie: movies[index],
                    onTap: () => _openMovie(movies[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
