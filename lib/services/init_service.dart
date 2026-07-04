import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/movie.dart'; // Tu modelo existente

class InitService {
  final DatabaseReference _videosRef = FirebaseDatabase.instance.ref('videos');


  Future<List<Movie>> loadMoviesFromJson() async {
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


  Future<void> initializeFirebaseWithMovies() async {
    try {
      // 1. Verificar si ya hay datos en Firebase
      final snapshot = await _videosRef.get();
      
      if (snapshot.exists) {
        print(' Firebase ya tiene datos. No se necesita inicializar.');
        return;
      }

      // 2. Cargar películas del JSON
      final movies = await loadMoviesFromJson();
      
      if (movies.isEmpty) {
        print(' No se encontraron películas en el JSON');
        return;
      }

      // 3. Subir cada película a Firebase
      print(' Subiendo ${movies.length} películas a Firebase...');
      
      for (var movie in movies) {
        // Generar un ID único para cada película
        final String id = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Convertir Movie a formato de Video para Firebase
        await _videosRef.child(id).set({
          'titulo': movie.titulo,
          'descripcion': movie.descripcion,
          'urlStorage': movie.trailerUrl, // Usamos el trailer como URL del video
          'miniatura': movie.imagenUrl,
          'duracion': movie.duracion,
          'genero': movie.genero,
          'fechaSubida': DateTime.now().toIso8601String(),
          'usuarioId': 'sistema',
          'anio': movie.anio,
          'director': movie.director,
        });
        
        print(' Subida: ${movie.titulo}');
      }
      
      print(' Todas las películas fueron subidas exitosamente!');
      
    } catch (e) {
      print(' Error al inicializar Firebase: $e');
      rethrow;
    }
  }

  // 🔹 VERIFICAR SI HAY DATOS EN FIREBASE
  Future<bool> hasDataInFirebase() async {
    try {
      final snapshot = await _videosRef.get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }
}