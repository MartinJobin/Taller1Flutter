import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/movie.dart';

class MovieService {
  Future<List<Movie>> loadMovies() async {
    try {
      final String response = await rootBundle.loadString('assets/peliculas.json');
      final Map<String, dynamic> data = json.decode(response);
      List<dynamic> moviesJson = data['peliculas'];
      return moviesJson.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      print("Error loading movies: $e");
      return [];
    }
  }

  List<Movie> filterByGenre(List<Movie> movies, String genero) {
    if (genero == 'Todas') return movies;
    return movies.where((movie) => movie.genero == genero).toList();
  }

  List<String> getGenres(List<Movie> movies) {
    Set<String> genres = {'Todas'};
    for (var movie in movies) {
      genres.add(movie.genero);
    }
    return genres.toList();
  }
}