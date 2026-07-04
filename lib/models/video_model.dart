class VideoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String urlStorage;
  final String miniatura;
  final String duracion;
  final String genero;
  final DateTime fechaSubida;
  final String usuarioId;

  VideoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.urlStorage,
    required this.miniatura,
    required this.duracion,
    required this.genero,
    required this.fechaSubida,
    required this.usuarioId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'urlStorage': urlStorage,
    'miniatura': miniatura,
    'duracion': duracion,
    'genero': genero,
    'fechaSubida': fechaSubida.toIso8601String(),
    'usuarioId': usuarioId,
  };

  factory VideoModel.fromJson(String id, Map<String, dynamic> json) {
    return VideoModel(
      id: id,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      urlStorage: json['urlStorage'] ?? '',
      miniatura: json['miniatura'] ?? '',
      duracion: json['duracion'] ?? '',
      genero: json['genero'] ?? '',
      fechaSubida: DateTime.tryParse(json['fechaSubida'] ?? '') ?? DateTime.now(),
      usuarioId: json['usuarioId'] ?? '',
    );
  }
}