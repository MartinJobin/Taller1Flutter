import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/video_model.dart';
import '../services/language_service.dart';
import '../services/video_service.dart';

import 'LectorQrScreen.dart';
import 'login_screen.dart';
import 'player_screen.dart';
import 'profile_screen.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  final LanguageService languageService;

  const HomeScreen({
    super.key,
    required this.languageService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VideoService _videoService = VideoService();

  StreamSubscription<List<VideoModel>>? _videosSubscription;

  List<VideoModel> _videos = [];

  bool _isLoading = true;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _listenVideos();
  }

  // Escucha las películas almacenadas en Firebase.
  void _listenVideos() {
    _videosSubscription =
        _videoService.getVideosStream().listen(
      (videos) {
        if (!mounted) return;

        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        final textos = AppLocalizations.of(context)!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${textos.moviesLoadError}: $error',
            ),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  // Cierra la sesión.
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          languageService: widget.languageService,
        ),
      ),
      (route) => false,
    );
  }

  // Confirma antes de cerrar sesión.
  void _confirmLogout() {
    final textos = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(textos.logout),
          content: Text(textos.logoutQuestion),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(textos.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(textos.logout),
            ),
          ],
        );
      },
    );
  }

  // Selector de idioma.
  void _showLanguageSelector() {
    final textos = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: Text(
            textos.selectLanguage,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Colors.red,
                ),
                title: Text(
                  textos.spanish,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                trailing:
                    widget.languageService.isSpanish
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : null,
                onTap: () async {
                  Navigator.pop(dialogContext);

                  await widget.languageService
                      .cambiarIdioma('es');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Colors.blue,
                ),
                title: Text(
                  textos.english,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                trailing:
                    !widget.languageService.isSpanish
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : null,
                onTap: () async {
                  Navigator.pop(dialogContext);

                  await widget.languageService
                      .cambiarIdioma('en');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Filtra por título o género.
  List<VideoModel> get _filteredVideos {
    if (_searchQuery.isEmpty) {
      return _videos;
    }

    final String query =
        _searchQuery.trim().toLowerCase();

    return _videos.where((video) {
      final String title =
          video.titulo.toLowerCase();

      final String genre =
          video.genero.toLowerCase();

      return title.contains(query) ||
          genre.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _videosSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          textos.appName,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Buscar.
          IconButton(
            tooltip: textos.search,
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch<VideoModel?>(
                context: context,
                delegate: VideoSearchDelegate(
                  videos: _videos,
                ),
              );
            },
          ),

          // Idioma.
          IconButton(
            tooltip: textos.language,
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            onPressed: _showLanguageSelector,
          ),

          // Lector QR.
          IconButton(
            tooltip: textos.scanQr,
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LectorQrScreen(),
                ),
              );
            },
          ),

          // Agregar película.
          IconButton(
            tooltip: textos.addMovie,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const UploadScreen(),
                ),
              );
            },
          ),

          // Perfil.
          IconButton(
            tooltip: textos.profile,
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProfileScreen(),
                ),
              );
            },
          ),

          // Salir.
          IconButton(
            tooltip: textos.logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : _videos.isEmpty
              ? _buildEmptyState()
              : _buildVideoGrid(),
    );
  }

  // Vista cuando no hay películas.
  Widget _buildEmptyState() {
    final textos = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              textos.noMovies,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              textos.addFirstMovie,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const UploadScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                textos.addMovie,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Catálogo.
  Widget _buildVideoGrid() {
    final textos = AppLocalizations.of(context)!;

    final List<VideoModel> videos =
        _filteredVideos;

    return Column(
      children: [
        if (_videos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    textos.all,
                    true,
                  ),
                  ..._getUniqueGenres().map(
                    (genre) => _buildFilterChip(
                      genre,
                      false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: videos.isEmpty
              ? Center(
                  child: Text(
                    textos.noResults,
                    style: const TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    int columns = 2;

                    if (constraints.maxWidth >=
                        1200) {
                      columns = 6;
                    } else if (constraints
                            .maxWidth >=
                        900) {
                      columns = 5;
                    } else if (constraints
                            .maxWidth >=
                        650) {
                      columns = 4;
                    } else if (constraints
                            .maxWidth >=
                        450) {
                      columns = 3;
                    }

                    return GridView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: videos.length,
                      itemBuilder:
                          (context, index) {
                        return _buildVideoCard(
                          videos[index],
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Lista de géneros únicos.
  List<String> _getUniqueGenres() {
    final Set<String> genres = {};

    for (final video in _videos) {
      if (video.genero.trim().isNotEmpty) {
        genres.add(video.genero);
      }
    }

    final List<String> genreList =
        genres.toList();

    genreList.sort();

    return genreList;
  }

  // Filtro por género.
  Widget _buildFilterChip(
    String label,
    bool isAll,
  ) {
    final bool isSelected = isAll
        ? _searchQuery.isEmpty
        : _searchQuery == label;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _searchQuery = isAll ? '' : label;
          });
        },
        backgroundColor: Colors.grey[900],
        selectedColor: Colors.red,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : Colors.white70,
        ),
      ),
    );
  }

  // Tarjeta de película.
  Widget _buildVideoCard(VideoModel video) {
    return GestureDetector(
      onTap: () {
        final String trailer =
            video.trailerUrl.trim();

        if (trailer.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Esta película no tiene un tráiler disponible',
              ),
              backgroundColor: Colors.red,
            ),
          );

          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              videoUrl: trailer,
              title: video.titulo,
              thumbnail: video.miniatura,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(12),
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: video.miniatura,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (
                    context,
                    url,
                  ) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child:
                            CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                  errorWidget: (
                    context,
                    url,
                    error,
                  ) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 45,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    video.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.red
                                .withOpacity(0.2),
                            borderRadius:
                                BorderRadius
                                    .circular(5),
                          ),
                          child: Text(
                            video.genero,
                            style:
                                const TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Spacer(),
                      Text(
                        video.duracion,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Buscador de películas.
class VideoSearchDelegate
    extends SearchDelegate<VideoModel?> {
  final List<VideoModel> videos;

  VideoSearchDelegate({
    required this.videos,
  });

  @override
  String get searchFieldLabel =>
      'Buscar película o género';

  @override
  ThemeData appBarTheme(
    BuildContext context,
  ) {
    final ThemeData theme =
        Theme.of(context);

    return theme.copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      inputDecorationTheme:
          const InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.white54,
        ),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(
    BuildContext context,
  ) {
    final textos =
        AppLocalizations.of(context)!;

    return [
      IconButton(
        tooltip: textos.clear,
        icon: const Icon(
          Icons.clear,
          color: Colors.white,
        ),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(
    BuildContext context,
  ) {
    final textos =
        AppLocalizations.of(context)!;

    return IconButton(
      tooltip: textos.back,
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    return _buildResultsList(
      context,
      _filterVideos(),
    );
  }

  @override
  Widget buildSuggestions(
    BuildContext context,
  ) {
    return _buildResultsList(
      context,
      _filterVideos(),
    );
  }

  List<VideoModel> _filterVideos() {
    final String normalizedQuery =
        query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return videos;
    }

    return videos.where((video) {
      return video.titulo
              .toLowerCase()
              .contains(normalizedQuery) ||
          video.genero
              .toLowerCase()
              .contains(normalizedQuery);
    }).toList();
  }

  Widget _buildResultsList(
    BuildContext context,
    List<VideoModel> results,
  ) {
    final textos =
        AppLocalizations.of(context)!;

    if (results.isEmpty) {
      return Center(
        child: Text(
          textos.noResults,
          style: const TextStyle(
            color: Colors.white54,
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final VideoModel video =
              results[index];

          return ListTile(
            leading: ClipRRect(
              borderRadius:
                  BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: video.miniatura,
                width: 55,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (
                  context,
                  url,
                ) {
                  return Container(
                    width: 55,
                    height: 70,
                    color: Colors.grey[800],
                    child: const Center(
                      child:
                          CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorWidget: (
                  context,
                  url,
                  error,
                ) {
                  return Container(
                    width: 55,
                    height: 70,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),
            title: Text(
              video.titulo,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              '${video.genero} · ${video.duracion}',
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
            trailing: const Icon(
              Icons.play_arrow,
              color: Colors.red,
            ),
            onTap: () {
              final String trailer =
                  video.trailerUrl.trim();

              if (trailer.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Esta película no tiene un tráiler disponible',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );

                return;
              }

              close(context, video);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(
                    videoUrl: trailer,
                    title: video.titulo,
                    thumbnail:
                        video.miniatura,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}