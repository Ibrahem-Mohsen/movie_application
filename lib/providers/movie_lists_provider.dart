import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../services/movie_database.dart';

class MovieListsProvider extends ChangeNotifier {
  MovieListsProvider(this._database);

  final MovieDatabase _database;
  final Map<MovieListType, List<Movie>> movies = {
    for (final type in MovieListType.values) type: <Movie>[],
  };
  final Map<int, Set<MovieListType>> _movieStatus = {};
  String? errorMessage;
  bool isLoading = false;
  String? _loadedUserId;

  bool isInList(int movieId, MovieListType type) =>
      _movieStatus[movieId]?.contains(type) ?? false;

  Future<void> loadAll(String userId) async {
    if (_loadedUserId != userId) {
      _loadedUserId = userId;
      for (final type in MovieListType.values) {
        movies[type] = [];
      }
      _movieStatus.clear();
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      for (final type in MovieListType.values) {
        movies[type] = await _database.getMovies(userId, type);
        for (final movie in movies[type]!) {
          _movieStatus.putIfAbsent(movie.id, () => <MovieListType>{}).add(type);
        }
      }
    } catch (_) {
      errorMessage = 'Could not read your saved lists.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovieStatus(String userId, int movieId) async {
    try {
      _movieStatus[movieId] = await _database.getMovieLists(userId, movieId);
      notifyListeners();
    } catch (_) {
      errorMessage = 'Could not read this movie’s saved lists.';
      notifyListeners();
    }
  }

  Future<void> toggleMovie(
    String userId,
    Movie movie,
    MovieListType type,
  ) async {
    errorMessage = null;
    final alreadySaved = isInList(movie.id, type);
    try {
      if (alreadySaved) {
        await _database.removeMovie(userId, movie.id, type);
        movies[type] = movies[type]!
            .where((savedMovie) => savedMovie.id != movie.id)
            .toList();
        _movieStatus[movie.id]?.remove(type);
      } else {
        await _database.addMovie(userId, movie, type);
        movies[type] = [...movies[type]!, movie];
        _movieStatus.putIfAbsent(movie.id, () => <MovieListType>{}).add(type);
      }
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Could not update the movie list: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = kDebugMode
          ? 'Could not update your list: $error'
          : 'Could not update your list. Please try again.';
      notifyListeners();
      rethrow;
    }
  }
}
