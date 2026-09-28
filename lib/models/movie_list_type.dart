enum MovieListType {
  favorite,
  watched,
  watching,
  wantToWatch;

  String get databaseValue => switch (this) {
    MovieListType.favorite => 'favorite',
    MovieListType.watched => 'watched',
    MovieListType.watching => 'watching',
    MovieListType.wantToWatch => 'want_to_watch',
  };

  String get title => switch (this) {
    MovieListType.favorite => 'Favorites',
    MovieListType.watched => 'Watched',
    MovieListType.watching => 'Watching',
    MovieListType.wantToWatch => 'Want to Watch',
  };

  String get description => switch (this) {
    MovieListType.favorite => 'Movies you love',
    MovieListType.watched => 'Movies you have finished',
    MovieListType.watching => 'Movies you are watching now',
    MovieListType.wantToWatch => 'Movies for another movie night',
  };
}
