import 'package:flutter/material.dart';

import '../services/tmdb_service.dart';

class MoviePoster extends StatelessWidget {
  const MoviePoster({super.key, required this.posterPath, this.width});

  final String? posterPath;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final path = posterPath;
    if (path == null || path.isEmpty) {
      return _placeholder(context);
    }

    return Image.network(
      '${TmdbService.imageBaseUrl}$path',
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          color: const Color(0xFF252830),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    width: width,
    color: const Color(0xFF252830),
    alignment: Alignment.center,
    child: const Icon(Icons.movie_outlined, size: 38, color: Colors.white38),
  );
}
