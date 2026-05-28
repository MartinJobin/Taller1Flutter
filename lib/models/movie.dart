class Movie {
  final String title;
  final String image;
  final String description;
  final String year;
  final String rating;
  final String genre;

  Movie({
    required this.title,
    required this.image,
    required this.description,
    this.year = "2024",
    this.rating = "7.5",
    this.genre = "Acción",
  });
}

// Lista de películas
final List<Movie> popularMovies = [
  Movie(
    title: "AVENGERS: ENDGAME",
    image: "https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg",
    description: "Los Vengadores se reúnen para enfrentar a Thanos y restaurar el orden en el universo.",
    year: "2019",
    rating: "8.4",
    genre: "Acción",
  ),
  Movie(
    title: "OPPENHEIMER",
    image: "https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg",
    description: "La historia del físico J. Robert Oppenheimer y su papel en la bomba atómica.",
    year: "2023",
    rating: "8.9",
    genre: "Drama",
  ),
  Movie(
    title: "SPIDER-MAN",
    image: "https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg",
    description: "Miles Morales regresa en una nueva aventura a través del multiverso.",
    year: "2023",
    rating: "8.8",
    genre: "Animación",
  ),
  Movie(
    title: "JOHN WICK 4",
    image: "https://image.tmdb.org/t/p/w500/vZloFAK7NmvMGKE7VkF5UHaz0I.jpg",
    description: "John Wick descubre un camino para derrotar a la Alta Mesa.",
    year: "2023",
    rating: "8.5",
    genre: "Acción",
  ),
  Movie(
    title: "BARBIE",
    image: "https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg",
    description: "Barbie y Ken viven en Barbieland, pero una crisis los lleva al mundo real.",
    year: "2023",
    rating: "7.8",
    genre: "Comedia",
  ),
];

final List<Movie> trendingMovies = [
  Movie(
    title: "THE BATMAN",
    image: "https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg",
    description: "Batman explora la corrupción en Gotham mientras persigue al Riddler.",
    year: "2022",
    rating: "8.4",
    genre: "Suspenso",
  ),
  Movie(
    title: "TOP GUN: MAVERICK",
    image: "https://image.tmdb.org/t/p/w500/62HCnUTziyWcpDaBO2i1DX17ljH.jpg",
    description: "Maverick enfrenta su pasado mientras entrena a nuevos pilotos.",
    year: "2022",
    rating: "8.6",
    genre: "Acción",
  ),
];

final List<Movie> newReleases = [
  Movie(
    title: "DUNE: PARTE 2",
    image: "https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dnbOE6PYpI4OFS8.jpg",
    description: "Paul Atreides se une a los Fremen en su búsqueda de venganza.",
    year: "2024",
    rating: "8.7",
    genre: "Ciencia Ficción",
  ),
];