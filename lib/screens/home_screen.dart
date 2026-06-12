import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart'; 
import '../widgets/movie_card.dart';
import 'profile_screen.dart';
import 'suggestions_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _moviesFuture;
  final MovieService _movieService = MovieService();
  String _selectedGenre = 'Todas';
  List<String> _genres = [];
  List<Movie> _allMovies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() async {
    _moviesFuture = _movieService.loadMovies();
    final movies = await _moviesFuture;
    setState(() {
      _allMovies = movies;
      _genres = _movieService.getGenres(movies);
    });
  }

  List<Movie> get _filteredMovies {
    return _movieService.filterByGenre(_allMovies, _selectedGenre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ITSQMETPLAY", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay películas', style: TextStyle(color: Colors.white)));
          }

          return Column(
            children: [
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _genres.length,
                  itemBuilder: (context, index) {
                    String genre = _genres[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(genre),
                        selected: _selectedGenre == genre,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGenre = genre;
                          });
                        },
                        backgroundColor: Colors.grey[900],
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(color: _selectedGenre == genre ? Colors.white : Colors.white70),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: _filteredMovies[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red, Colors.black]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text("ITSQMETPLAY", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Cine Total", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.red),
              title: const Text("Inicio", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.red),
              title: const Text("Mi Perfil", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.red),
              title: const Text("Membresía", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showPaymentDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text("Sugerencias", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SuggestionsScreen()));
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Membresía Premium", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("💰 \$9.99 / mes", style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 10),
            const Text("✓ Sin publicidad", style: TextStyle(color: Colors.white70)),
            const Text("✓ Contenido exclusivo", style: TextStyle(color: Colors.white70)),
            const Text("✓ Descargas offline", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 ¡Suscripción completada!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Suscribirse Ahora"),
            ),
          ],
        ),
      ),
    );
  }
}