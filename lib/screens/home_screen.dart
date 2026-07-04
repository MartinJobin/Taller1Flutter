import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/video_service.dart';
import '../models/video_model.dart';
import 'player_screen.dart';
import 'profile_screen.dart';
import 'upload_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VideoService _videoService = VideoService();
  List<VideoModel> _videos = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _listenVideos();
  }

  // ✅ ESCUCHAR CAMBIOS EN TIEMPO REAL
  void _listenVideos() {
    _videoService.getVideosStream().listen((videos) {
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() => _isLoading = false);
      print('Error en listener: $error');
    });
  }

  // ✅ CERRAR SESIÓN
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // ✅ FILTRAR POR BÚSQUEDA
  List<VideoModel> get _filteredVideos {
    if (_searchQuery.isEmpty) return _videos;
    return _videos.where((video) =>
      video.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      video.genero.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CINESTREAM", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        actions: [
          // 🔹 Buscar
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _VideoSearchDelegate(_videos),
              );
            },
          ),
          // 🔹 Subir
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
            },
          ),
          // 🔹 Perfil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          // 🔹 Cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _videos.isEmpty
              ? _buildEmptyState()
              : _buildVideoGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No hay videos disponibles',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Sube tu primer video o espera a que el admin agregue contenido',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Subir Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    final videos = _filteredVideos;
    
    return Column(
      children: [
        // 🔹 Barra de filtros
        if (_videos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos'),
                  ..._getUniqueGenres().map((genre) => _buildFilterChip(genre)),
                ],
              ),
            ),
          ),
        
        // 🔹 Grid de videos
        Expanded(
          child: videos.isEmpty
              ? Center(
                  child: Text(
                    'No se encontraron resultados',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildVideoCard(video);
                  },
                ),
        ),
      ],
    );
  }

  List<String> _getUniqueGenres() {
    final genres = <String>{};
    for (var video in _videos) {
      genres.add(video.genero);
    }
    return genres.toList();
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _searchQuery == label && label != 'Todos',
        onSelected: (selected) {
          setState(() {
            _searchQuery = selected && label != 'Todos' ? label : '';
          });
        },
        backgroundColor: Colors.grey[900],
        selectedColor: Colors.red,
        labelStyle: TextStyle(
          color: _searchQuery == label && label != 'Todos' ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              videoUrl: video.urlStorage,
              title: video.titulo,
              thumbnail: video.miniatura,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Miniatura
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: video.miniatura,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator(color: Colors.red)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.red, size: 40),
                ),
              ),
            ),
            // 📝 Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.genero,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      ),
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

// 🔍 DELEGADO DE BÚSQUEDA
class _VideoSearchDelegate extends SearchDelegate {
  final List<VideoModel> videos;

  _VideoSearchDelegate(this.videos);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = videos.where((video) =>
      video.titulo.toLowerCase().contains(query.toLowerCase()) ||
      video.genero.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return results.isEmpty
        ? const Center(
            child: Text(
              'No se encontraron resultados',
              style: TextStyle(color: Colors.white54),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final video = results[index];
              return GestureDetector(
                onTap: () {
                  close(context, null);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(
                        videoUrl: video.urlStorage,
                        title: video.titulo,
                        thumbnail: video.miniatura,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[900],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: video.miniatura,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            color: Colors.grey[800],
                            child: const Center(child: CircularProgressIndicator(color: Colors.red)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, color: Colors.red),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          video.titulo,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = videos.where((video) =>
      video.titulo.toLowerCase().contains(query.toLowerCase()) ||
      video.genero.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final video = suggestions[index];
        return ListTile(
          leading: CachedNetworkImage(
            imageUrl: video.miniatura,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(color: Colors.red),
          ),
          title: Text(video.titulo, style: const TextStyle(color: Colors.white)),
          subtitle: Text(video.genero, style: TextStyle(color: Colors.white54)),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerScreen(
                  videoUrl: video.urlStorage,
                  title: video.titulo,
                  thumbnail: video.miniatura,
                ),
              ),
            );
          },
        );
      },
    );
  }
}