import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/video_model.dart';
import 'firebase_service.dart';

class VideoService {
  // REFERENCIA A LA BASE DE DATOS
  final DatabaseReference _videosRef = FirebaseService.database.child('videos');
  
  // STREAM PARA ESCUCHAR CAMBIOS EN TIEMPO REAL
  Stream<List<VideoModel>> getVideosStream() {
    return _videosRef.onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      
      if (data == null) return [];
      
      return data.entries.map((entry) {
        // Convertir a Map<String, dynamic> correctamente
        final Map<String, dynamic> videoData = 
            Map<String, dynamic>.from(entry.value as Map);
        return VideoModel.fromJson(entry.key, videoData);
      }).toList();
    });
  }

  // OBTENER VIDEOS UNA VEZ (FUTURE)
  Future<List<VideoModel>> getVideos() async {
    final snapshot = await _videosRef.get();
    final Map<dynamic, dynamic>? data = snapshot.value as Map?;

    if (data == null) return [];

    return data.entries.map((entry) {
      // Convertir Map<dynamic, dynamic> a Map<String, dynamic>
      final Map<String, dynamic> videoData = 
          Map<String, dynamic>.from(entry.value as Map);
      return VideoModel.fromJson(entry.key, videoData);
    }).toList();
  }

  // GUARDAR VIDEO
  Future<void> saveVideo(VideoModel video) async {
    await _videosRef.child(video.id).set(video.toJson());
  }

  // ELIMINAR VIDEO
  Future<void> deleteVideo(String videoId) async {
    await _videosRef.child(videoId).remove();
  }

  // SUBIR VIDEO A STORAGE (implementación completa)
  Future<String> uploadVideo(String filePath, String fileName) async {
    try {
      final ref = FirebaseService.storage
          .ref()
          .child('videos/$fileName');
      
      // Usar file_picker para obtener el archivo
      final file = await _getFile(filePath);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo video: $e');
      throw Exception('Error al subir video: $e');
    }
  }

  // SUBIR MINIATURA
  Future<String> uploadThumbnail(String filePath, String fileName) async {
    try {
      final ref = FirebaseService.storage
          .ref()
          .child('thumbnails/$fileName');
      
      final file = await _getFile(filePath);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error subiendo miniatura: $e');
      throw Exception('Error al subir miniatura: $e');
    }
  }

  // FUNCIÓN AUXILIAR PARA OBTENER ARCHIVO
  Future<dynamic> _getFile(String path) async {
    // Usar file_picker para obtener archivos desde la UI
    throw UnimplementedError('Usar file_picker para obtener archivos');
  }
}