import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/video_model.dart';
import 'firebase_service.dart';
import 'video_service.dart';

class MovieUploader {
  static final VideoService _videoService =
      VideoService();

  // Sube las películas del archivo JSON a Firebase.
  static Future<void> uploadMoviesFromJson() async {
    try {
      print('Cargando películas desde JSON...');

      // 1. Cargar el archivo JSON.
      final String jsonString =
          await rootBundle.loadString(
        'assets/peliculas.json',
      );

      final dynamic decodedData =
          json.decode(jsonString);

      if (decodedData is! List) {
        throw const FormatException(
          'El archivo peliculas.json debe contener una lista de películas',
        );
      }

      final List<dynamic> jsonData = decodedData;

      print(
        '${jsonData.length} películas encontradas',
      );

      // 2. Convertir y guardar cada película.
      int count = 0;

      for (final dynamic item in jsonData) {
        if (item is! Map) {
          print(
            'Registro omitido porque no tiene un formato válido',
          );
          continue;
        }

        final Map<String, dynamic> movieData =
            Map<String, dynamic>.from(item);

        final Map<String, dynamic> enlaces =
            movieData['enlaces'] is Map
                ? Map<String, dynamic>.from(
                    movieData['enlaces'],
                  )
                : <String, dynamic>{};

        final Map<String, dynamic> detalles =
            movieData['detalles'] is Map
                ? Map<String, dynamic>.from(
                    movieData['detalles'],
                  )
                : <String, dynamic>{};

        final String titulo =
            movieData['titulo']
                    ?.toString()
                    .trim() ??
                'Sin título';

        final String descripcion =
            movieData['descripcion']
                    ?.toString()
                    .trim() ??
                '';

        final String imagenUrl =
            enlaces['image']
                    ?.toString()
                    .trim() ??
                '';

        final String trailerUrl =
            enlaces['trailer']
                    ?.toString()
                    .trim() ??
                '';

        final String genero =
            movieData['genero']
                    ?.toString()
                    .trim() ??
                'Otro';

        final String duracion =
            detalles['duracion']
                    ?.toString()
                    .trim() ??
                'N/A';

        if (trailerUrl.isEmpty) {
          print(
            'Película omitida: "$titulo" no tiene tráiler',
          );
          continue;
        }

        final DatabaseReference videoReference =
            FirebaseService.database
                .child('videos')
                .push();

        final String? generatedId =
            videoReference.key;

        if (generatedId == null) {
          print(
            'No se pudo generar un ID para "$titulo"',
          );
          continue;
        }

        final VideoModel video = VideoModel(
          id: generatedId,
          titulo: titulo,
          descripcion: descripcion,
          trailerUrl: trailerUrl,
          miniatura: imagenUrl,
          duracion: duracion,
          genero: genero,
          fechaSubida: DateTime.now(),
          usuarioId: 'system',
        );

        await _videoService.saveVideo(video);

        count++;

        print(
          '$count. "$titulo" subida a Firebase',
        );
      }

      print(
        '$count películas subidas exitosamente a Firebase',
      );
    } catch (e) {
      print(
        'Error subiendo películas: $e',
      );

      throw Exception(
        'Error al subir películas: $e',
      );
    }
  }

  // Verifica si ya existen películas en Firebase.
  static Future<bool> hasMoviesInFirebase() async {
    try {
      final DatabaseReference reference =
          FirebaseService.database.child('videos');

      final DataSnapshot snapshot =
          await reference.get();

      if (!snapshot.exists ||
          snapshot.value == null) {
        return false;
      }

      final dynamic value = snapshot.value;

      if (value is Map) {
        return value.isNotEmpty;
      }

      if (value is List) {
        return value.isNotEmpty;
      }

      return false;
    } catch (e) {
      print(
        'Error verificando películas: $e',
      );

      return false;
    }
  }
}