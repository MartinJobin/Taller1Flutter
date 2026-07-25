import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/init_service.dart';
import '../services/language_service.dart';

import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final LanguageService languageService;

  const SplashScreen({
    super.key,
    required this.languageService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final InitService _initService = InitService();

  String _statusMessage = 'Inicializando...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _statusMessage = 'Verificando autenticación...';
        _progress = 0.2;
      });

      final User? user = FirebaseAuth.instance.currentUser;

      setState(() {
        _statusMessage = 'Verificando datos de películas...';
        _progress = 0.5;
      });

      final bool hasData =
          await _initService.hasDataInFirebase();

      if (!hasData) {
        setState(() {
          _statusMessage =
              'Cargando cartelera por primera vez...';
          _progress = 0.7;
        });

        await _initService
            .initializeFirebaseWithMovies();
      }

      setState(() {
        _statusMessage = '¡Listo!';
        _progress = 1.0;
      });

      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              languageService:
                  widget.languageService,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              languageService:
                  widget.languageService,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Error: $e';
        _progress = 0;
      });

      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF1A1A2E),
          title: const Text(
            '❌ Error',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Text(
            'Error al inicializar la app:\n$error',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeApp();
              },
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.movie_filter,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'CINESTREAM',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Taller 2 - Firebase',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white
                      .withOpacity(0.2),
                  color: Colors.white,
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}