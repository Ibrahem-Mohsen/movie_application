class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage = 0,
    this.genreIds = const [],
    this.genres = const [],
    this.runtime,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final List<int> genreIds;
  final List<String> genres;
  final int? runtime;

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawGenreIds = json['genre_ids'] as List<dynamic>? ?? const [];
    final rawGenres = json['genres'] as List<dynamic>? ?? const [];

    return Movie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['name'] ?? 'Untitled').toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genreIds: rawGenreIds.map((value) => (value as num).toInt()).toList(),
      genres: rawGenres
          .map((value) => (value as Map<String, dynamic>)['name'].toString())
          .toList(),
      runtime: (json['runtime'] as num?)?.toInt(),
    );
  }

  factory Movie.fromDatabase(Map<String, Object?> row) {
    final genreText = row['genres'] as String? ?? '';
    return Movie(
      id: row['movie_id'] as int,
      title: row['title'] as String,
      overview: row['overview'] as String? ?? '',
      posterPath: row['poster_path'] as String?,
      backdropPath: row['backdrop_path'] as String?,
      releaseDate: row['release_date'] as String?,
      voteAverage: (row['vote_average'] as num?)?.toDouble() ?? 0,
      genres: genreText.isEmpty ? const [] : genreText.split('|'),
      runtime: row['runtime'] as int?,
    );
  }

  Map<String, Object?> toDatabaseMap() => {
    'movie_id': id,
    'title': title,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'release_date': releaseDate,
    'vote_average': voteAverage,
    'genres': genres.join('|'),
    'runtime': runtime,
  };
}
