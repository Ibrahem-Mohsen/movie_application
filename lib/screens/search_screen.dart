import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/state_views.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      context.read<MovieProvider>().search('');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<MovieProvider>().search(query);
    });
  }

  void _openMovie(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search movies',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Movie title',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_searchController.text.trim().isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  title: 'Search TMDB',
                  message: 'Type a movie title to see matching results.',
                ),
              )
            else if (provider.isSearching)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingView(message: 'Searching movies...'),
              )
            else if (provider.searchError != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  message: provider.searchError!,
                  onRetry: () => provider.search(_searchController.text),
                ),
              )
            else if (provider.searchResults.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  title: 'No movies found',
                  message: 'Try another title or check the spelling.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid.builder(
                  itemCount: provider.searchResults.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.53,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) => MovieCard(
                    width: double.infinity,
                    movie: provider.searchResults[index],
                    onTap: () => _openMovie(provider.searchResults[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
