import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/video_model.dart';
import 'firebase_service.dart';

class VideoService {
  // Referencia al nodo videos en Realtime Database.
  final DatabaseReference _videosRef =
      FirebaseService.database.child('videos');

  // Escucha los cambios en tiempo real.
  Stream<List<VideoModel>> getVideosStream() {
    return _videosRef.onValue.map((event) {
      final Object? value = event.snapshot.value;

      if (value == null || value is! Map) {
        return <VideoModel>[];
      }

      final List<VideoModel> videos = [];

      value.forEach((key, data) {
        if (data is Map) {
          final Map<String, dynamic> videoData =
              Map<String, dynamic>.from(data);

          videos.add(
            VideoModel.fromJson(
              key.toString(),
              videoData,
            ),
          );
        }
      });

      return videos;
    });
  }

  // Obtiene los videos una sola vez.
  Future<List<VideoModel>> getVideos() async {
    final DataSnapshot snapshot = await _videosRef.get();
    final Object? value = snapshot.value;

    if (value == null || value is! Map) {
      return [];
    }

    final List<VideoModel> videos = [];

    value.forEach((key, data) {
      if (data is Map) {
        final Map<String, dynamic> videoData =
            Map<String, dynamic>.from(data);

        videos.add(
          VideoModel.fromJson(
            key.toString(),
            videoData,
          ),
        );
      }
    });

    return videos;
  }

  // Guarda la información del video en Realtime Database.
  Future<void> saveVideo(VideoModel video) async {
    await _videosRef.child(video.id).set(video.toJson());
  }

  // Elimina la información del video.
  Future<void> deleteVideo(String videoId) async {
    await _videosRef.child(videoId).remove();
  }

  // Sube el video a Firebase Storage usando bytes.
  Future<String> uploadVideo(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final Reference storageRef = FirebaseService.storage
          .ref()
          .child('videos')
          .child(fileName);

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'video/mp4',
      );

      await storageRef.putData(
        fileBytes,
        metadata,
      );

      return await storageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception(
        'Firebase Storage no pudo subir el video: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Error al subir el video: $e',
      );
    }
  }

  // Sube la miniatura a Firebase Storage usando bytes.
  Future<String> uploadThumbnail(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final Reference storageRef = FirebaseService.storage
          .ref()
          .child('thumbnails')
          .child(fileName);

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      await storageRef.putData(
        fileBytes,
        metadata,
      );

      return await storageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception(
        'Firebase Storage no pudo subir la miniatura: ${e.message}',
      );
    } catch (e) {
      throw Exception(
        'Error al subir la miniatura: $e',
      );
    }
  }
}