import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieProvider extends ChangeNotifier {
  MovieProvider(this._service);

  final TmdbService _service;

  static const sections = <String, String>{
    'Popular': 'popular',
    'Now Playing': 'now_playing',
    'Top Rated': 'top_rated',
    'Upcoming': 'upcoming',
  };

  final Map<String, List<Movie>> moviesBySection = {};
  final Map<String, String> sectionErrors = {};
  bool isLoadingHome = false;
  String? searchError;
  bool isSearching = false;
  List<Movie> searchResults = [];
  int _searchRequest = 0;

  Future<void> loadHome() async {
    isLoadingHome = true;
    sectionErrors.clear();
    notifyListeners();

    await Future.wait(
      sections.entries.map((section) async {
        try {
          moviesBySection[section.key] = await _service.getMovies(
            section.value,
          );
        } catch (error) {
          sectionErrors[section.key] = error.toString();
        }
        notifyListeners();
      }),
    );

    isLoadingHome = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    final requestNumber = ++_searchRequest;
    final cleanedQuery = query.trim();
    if (cleanedQuery.isEmpty) {
      searchResults = [];
      searchError = null;
      isSearching = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    searchError = null;
    notifyListeners();
    try {
      final results = await _service.searchMovies(cleanedQuery);
      if (requestNumber == _searchRequest) searchResults = results;
    } catch (error) {
      if (requestNumber == _searchRequest) {
        searchError = error.toString();
        searchResults = [];
      }
    } finally {
      if (requestNumber == _searchRequest) {
        isSearching = false;
        notifyListeners();
      }
    }
  }

  Future<Movie> getDetails(int movieId) => _service.getMovieDetails(movieId);
}
