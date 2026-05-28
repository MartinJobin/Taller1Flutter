import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/category_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CINESTREAM", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.red, Colors.black]),
                borderRadius: BorderRadius.circular(0),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_filled, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text("BIENVENIDO A CINESTREAM", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Miles de películas disponibles", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            
            // Populares
            const CategoryTitle(title: "🔥 POPULARES"),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popularMovies.length,
                itemBuilder: (context, index) => MovieCard(movie: popularMovies[index]),
              ),
            ),
            
            // Tendencias
            const CategoryTitle(title: "📈 TENDENCIAS"),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trendingMovies.length,
                itemBuilder: (context, index) => MovieCard(movie: trendingMovies[index]),
              ),
            ),
            
            // Nuevos estrenos
            const CategoryTitle(title: "✨ NUEVOS ESTRENOS"),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newReleases.length,
                itemBuilder: (context, index) => MovieCard(movie: newReleases[index]),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}