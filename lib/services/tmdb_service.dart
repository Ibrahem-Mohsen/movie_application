import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';

class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const _apiKey = 'YOUR_TMDB_API_KEY';
  final http.Client _client;

  Future<List<Movie>> getMovies(String category) async {
    final data = await _get('/movie/$category');
    return _readMovieResults(data);
  }

  Future<List<Movie>> searchMovies(String query) async {
    final data = await _get('/search/movie', {'query': query});
    return _readMovieResults(data);
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final data = await _get('/movie/$movieId');
    return Movie.fromJson(data);
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String> extraParameters = const {},
  ]) async {
    if (_apiKey == 'YOUR_TMDB_API_KEY') {
      throw const TmdbException(
        'Add your TMDB API key in TmdbService before running the app.',
      );
    }

    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'en-US',
        ...extraParameters,
      },
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = body is Map<String, dynamic>
            ? (body['status_message'] ?? 'TMDB request failed').toString()
            : 'TMDB request failed';
        throw TmdbException(message);
      }

      if (body is! Map<String, dynamic>) {
        throw const TmdbException('TMDB returned an unexpected response.');
      }
      return body;
    } on TmdbException {
      rethrow;
    } catch (error) {
      throw TmdbException(
        'Could not load movies. Check your connection. ($error)',
      );
    }
  }

  List<Movie> _readMovieResults(Map<String, dynamic> data) {
    final results = data['results'];
    if (results is! List) {
      throw const TmdbException('TMDB returned an unexpected movie list.');
    }
    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
  }
}

class TmdbException implements Exception {
  const TmdbException(this.message);

  final String message;

  @override
  String toString() => message;
}

