import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String trailerUrl;
  final String miniatura;
  final String duracion;
  final String genero;
  final DateTime fechaSubida;
  final String usuarioId;

  const VideoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.trailerUrl,
    required this.miniatura,
    required this.duracion,
    required this.genero,
    required this.fechaSubida,
    required this.usuarioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'trailerUrl': trailerUrl,
      'miniatura': miniatura,
      'duracion': duracion,
      'genero': genero,
      'fechaSubida': Timestamp.fromDate(fechaSubida),
      'usuarioId': usuarioId,
    };
  }

  factory VideoModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    final dynamic fecha =
        json['fechaSubida'] ?? json['createdAt'];

    DateTime fechaConvertida = DateTime.now();

    if (fecha is Timestamp) {
      fechaConvertida = fecha.toDate();
    } else if (fecha is String) {
      fechaConvertida =
          DateTime.tryParse(fecha) ?? DateTime.now();
    }

    final Map<String, dynamic> enlaces =
        json['enlaces'] is Map
            ? Map<String, dynamic>.from(json['enlaces'])
            : {};

    final Map<String, dynamic> detalles =
        json['detalles'] is Map
            ? Map<String, dynamic>.from(json['detalles'])
            : {};

    final String trailer = _firstNotEmpty([
      json['trailerUrl'],
      json['trailer'],
      enlaces['trailer'],
      json['urlVideo'],
      json['urlStorage'],
      json['urlEspanol'],
    ]);

    final String miniatura = _firstNotEmpty([
      json['miniatura'],
      enlaces['image'],
    ]);

    final String duracion = _firstNotEmpty([
      json['duracion'],
      detalles['duracion'],
    ]);

    return VideoModel(
      id: id,
      titulo: json['titulo']?.toString().trim() ?? '',
      descripcion:
          json['descripcion']?.toString().trim() ?? '',
      trailerUrl: trailer,
      miniatura: miniatura,
      duracion: duracion,
      genero: json['genero']?.toString().trim() ?? '',
      fechaSubida: fechaConvertida,
      usuarioId:
          json['usuarioId']?.toString().trim() ?? '',
    );
  }

  static String _firstNotEmpty(
    List<dynamic> values,
  ) {
    for (final dynamic value in values) {
      final String text =
          value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }
}