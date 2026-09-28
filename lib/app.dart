import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/movie_lists_provider.dart';
import 'providers/movie_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';
import 'services/movie_database.dart';
import 'services/tmdb_service.dart';
import 'theme/app_theme.dart';

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => MovieProvider(TmdbService())),
        ChangeNotifierProvider(
          create: (_) => MovieListsProvider(MovieDatabase()),
        ),
      ],
      child: MaterialApp(
        title: 'MoviesApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _AppStart(),
      ),
    );
  }
}

class _AppStart extends StatelessWidget {
  const _AppStart();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthProvider>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return MainNavigationScreen(user: user);
      },
    );
  }
}
