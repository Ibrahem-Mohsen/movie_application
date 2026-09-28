import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';

class MovieDatabase {
  static const _databaseName = 'moviesapp.db';
  static const _tableName = 'user_movies';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = path.join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_tableName (
            user_id TEXT NOT NULL,
            movie_id INTEGER NOT NULL,
            list_type TEXT NOT NULL,
            title TEXT NOT NULL,
            overview TEXT NOT NULL,
            poster_path TEXT,
            backdrop_path TEXT,
            release_date TEXT,
            vote_average REAL NOT NULL,
            genres TEXT NOT NULL,
            runtime INTEGER,
            PRIMARY KEY (user_id, movie_id, list_type)
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> addMovie(
    String userId,
    Movie movie,
    MovieListType listType,
  ) async {
    final db = await database;
    await db.insert(_tableName, {
      'user_id': userId,
      'list_type': listType.databaseValue,
      ...movie.toDatabaseMap(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeMovie(
    String userId,
    int movieId,
    MovieListType listType,
  ) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'user_id = ? AND movie_id = ? AND list_type = ?',
      whereArgs: [userId, movieId, listType.databaseValue],
    );
  }

  Future<List<Movie>> getMovies(String userId, MovieListType listType) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'user_id = ? AND list_type = ?',
      whereArgs: [userId, listType.databaseValue],
      orderBy: 'title COLLATE NOCASE',
    );
    return rows.map(Movie.fromDatabase).toList();
  }

  Future<Set<MovieListType>> getMovieLists(String userId, int movieId) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      columns: ['list_type'],
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
    return rows
        .map(
          (row) => MovieListType.values.firstWhere(
            (type) => type.databaseValue == row['list_type'],
          ),
        )
        .toSet();
  }
}
