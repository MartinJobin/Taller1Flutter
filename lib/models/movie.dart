class Movie {
  final String titulo;
  final int anio;
  final String descripcion;
  final String imagenUrl;
  final String trailerUrl;
  final String genero;
  final String duracion;
  final String director;

  Movie({
    required this.titulo,
    required this.anio,
    required this.descripcion,
    required this.imagenUrl,
    required this.trailerUrl,
    required this.genero,
    required this.duracion,
    required this.director,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      titulo: json['titulo'],
      anio: json['anio'],
      descripcion: json['descripcion'],
      imagenUrl: json['enlaces']['image'],
      trailerUrl: json['enlaces']['trailer'],
      genero: json['genero'],
      duracion: json['detalles']['duracion'],
      director: json['detalles']['director'],
    );
  }
}