import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.red,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mi usuario",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "miusuario@gmail.com",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            _buildInfoCard("Películas vistas", "12"),
            _buildInfoCard("Lista de deseos", "5"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Share.share('¡Mira CINESTREAM! La mejor app de streaming');
              },
              icon: const Icon(Icons.share),
              label: const Text("Compartir App"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: const Color(0xFF1A1A2E),  // ← Corregido: 0xFF no @xF
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(value, style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );  
  } 
} 