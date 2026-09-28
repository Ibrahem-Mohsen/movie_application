# MoviesApp

MoviesApp is a Flutter graduation project for the ITI Flutter track. It lets users browse movies, search TMDB, and organize movies into lists.

## Features

- Email/password registration, login, and logout with Firebase Authentication.
- Popular, Now Playing, Top Rated, and Upcoming movies.
- Movie search and details.
- Favorites, Watched, Watching, and Want to Watch lists.
- SQLite storage for each signed-in user's lists.

## Technologies

Flutter, Provider, TMDB API, Firebase Authentication, and SQLite (`sqflite`).

## Project structure

- `screens/` and `widgets/`: app pages and reusable UI.
- `providers/`: shared app state and actions.
- `services/`: TMDB, Firebase Authentication, and SQLite.
- `models/`: movie data and list types.

Provider connects the screens to the services, keeping the project small and easy to follow.

## Run the app

From the project folder, run:

```bash
flutter pub get
flutter run
```

Firebase is already configured for the project. The TMDB key and Firebase client configuration are included for this course submission, so keep the repository **private** and give the evaluator access.

## Database

SQLite stores the four lists on the current device. Lists are separated by Firebase user ID, but do not sync between devices.
