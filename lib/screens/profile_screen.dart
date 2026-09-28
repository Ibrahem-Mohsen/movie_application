import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuthException, User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 34,
            child: Icon(Icons.person_outline, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            user.email ?? 'Movie fan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 28),
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Your movie lists are saved on this device'),
            subtitle: Text('They stay here when you close and reopen the app.'),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About movie data'),
            subtitle: const Text('TMDB attribution'),
            contentPadding: EdgeInsets.zero,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'MoviesApp',
              children: const [
                Text(
                  'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                ),
                SizedBox(height: 12),
                Text(
                  'Movie data and images are provided by The Movie Database (TMDB).',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                await context.read<AuthProvider>().logout();
              } on FirebaseAuthException catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.message ?? 'Could not log out.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
