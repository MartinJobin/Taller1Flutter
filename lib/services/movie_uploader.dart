import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_database/firebase_database.dart';
import '../models/video_model.dart';
import 'video_service.dart';
import 'firebase_service.dart';

class MovieUploader {
  static final VideoService _videoService = VideoService();

  // 🔹 SUBIR PELÍCULAS DESDE JSON A FIREBASE
  static Future<void> uploadMoviesFromJson() async {
    try {
      print(' Cargando películas desde JSON...');
      
      // 1. Cargar el archivo JSON
      final String jsonString = await rootBundle.loadString('assets/peliculas.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      print(' ${jsonData.length} películas encontradas');
      
      // 2. Convertir cada película a VideoModel
      int count = 0;
      for (var item in jsonData) {
        final String id = DateTime.now().millisecondsSinceEpoch.toString() + '_$count';
        
        // Obtener datos de la película (usando las mismas keys que en tu JSON)
        final String titulo = item['titulo'] ?? 'Sin título';
        final String descripcion = item['descripcion'] ?? '';
        final String imagenUrl = item['enlaces']?['image'] ?? '';
        final String trailerUrl = item['enlaces']?['trailer'] ?? '';
        final String genero = item['genero'] ?? 'Otro';
        final String duracion = item['detalles']?['duracion'] ?? 'N/A';
        
        // Crear VideoModel (usando los campos que realmente tiene tu modelo)
        final video = VideoModel(
          id: id,
          titulo: titulo,
          descripcion: descripcion,
          urlStorage: trailerUrl, // Usamos el trailer como URL del video
          miniatura: imagenUrl,
          duracion: duracion,
          genero: genero,
          fechaSubida: DateTime.now(),  // ← CAMPO CORRECTO
          usuarioId: 'system',          // ← CAMPO CORRECTO
        );
        
        // 3. Guardar en Firebase
        await _videoService.saveVideo(video);
        count++;
        print('✅ $count. "$titulo" subida a Firebase');
      }
      
      print(' ¡$count películas subidas exitosamente a Firebase!');
      
    } catch (e) {
      print(' Error subiendo películas: $e');
      throw Exception('Error al subir películas: $e');
    }
  }

  // 🔹 VERIFICAR SI YA HAY PELÍCULAS EN FIREBASE
  static Future<bool> hasMoviesInFirebase() async {
    try {
      final DatabaseReference ref = FirebaseService.database.child('videos');
      final snapshot = await ref.get();
      return snapshot.exists && (snapshot.value as Map?)?.isNotEmpty == true;
    } catch (e) {
      print('Error verificando películas: $e');
      return false;
    }
  }
}