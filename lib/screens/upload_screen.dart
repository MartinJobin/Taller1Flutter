import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/video_model.dart';
import '../services/firebase_service.dart';
import '../services/video_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() {
    return _UploadScreenState();
  }
}

class _UploadScreenState extends State<UploadScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _tituloController =
      TextEditingController();

  final TextEditingController _descripcionController =
      TextEditingController();

  final TextEditingController _generoController =
      TextEditingController();

  final TextEditingController _duracionController =
      TextEditingController();

  final TextEditingController _trailerController =
      TextEditingController();

  final TextEditingController _miniaturaController =
      TextEditingController();

  final VideoService _videoService = VideoService();

  bool _isUploading = false;

  String _uploadMessage = '';

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _generoController.dispose();
    _duracionController.dispose();
    _trailerController.dispose();
    _miniaturaController.dispose();

    super.dispose();
  }

  Future<void> _uploadVideo() async {
    final bool validForm =
        _formKey.currentState?.validate() ?? false;

    if (!validForm) {
      return;
    }

    final String trailerUrl =
        _trailerController.text.trim();

    final String? videoId =
        YoutubePlayerController.convertUrlToId(
      trailerUrl,
    );

    if (videoId == null || videoId.isEmpty) {
      _showMessage(
        'Ingresa un enlace válido de YouTube',
        Colors.orange,
      );

      return;
    }

    final currentUser = FirebaseService.currentUser;

    if (currentUser == null) {
      _showMessage(
        'Debes iniciar sesión para agregar una película',
        Colors.red,
      );

      return;
    }

    setState(() {
      _isUploading = true;
      _uploadMessage =
          'Guardando información de la película...';
    });

    try {
      final databaseReference =
          FirebaseService.database
              .child('videos')
              .push();

      final String? generatedId =
          databaseReference.key;

      if (generatedId == null) {
        throw Exception(
          'No se pudo generar el identificador de la película',
        );
      }

      final VideoModel video = VideoModel(
        id: generatedId,
        titulo: _tituloController.text.trim(),
        descripcion:
            _descripcionController.text.trim(),
        trailerUrl: trailerUrl,
        miniatura:
            _miniaturaController.text.trim(),
        duracion:
            _duracionController.text.trim(),
        genero: _generoController.text.trim(),
        fechaSubida: DateTime.now(),
        usuarioId: currentUser.uid,
      );

      await _videoService.saveVideo(video);

      if (!mounted) {
        return;
      }

      _showMessage(
        'Película agregada correctamente',
        Colors.green,
      );

      _clearForm();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'No se pudo guardar la película: $e',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadMessage = '';
        });
      }
    }
  }

  void _clearForm() {
    _tituloController.clear();
    _descripcionController.clear();
    _generoController.clear();
    _duracionController.clear();
    _trailerController.clear();
    _miniaturaController.clear();

    setState(() {});
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    return null;
  }

  String? _youtubeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El enlace del tráiler es obligatorio';
    }

    final String? videoId =
        YoutubePlayerController.convertUrlToId(
      value.trim(),
    );

    if (videoId == null || videoId.isEmpty) {
      return 'Ingresa un enlace válido de YouTube';
    }

    return null;
  }

  String? _imageUrlValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La URL de la imagen es obligatoria';
    }

    final Uri? uri = Uri.tryParse(value.trim());

    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https')) {
      return 'Ingresa una URL de imagen válida';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Agregar película',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.movie_creation_outlined,
                  size: 70,
                  color: Colors.red,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Agregar una película',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa los datos y el enlace del tráiler oficial de YouTube',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                _buildTextField(
                  controller: _tituloController,
                  label: 'Título',
                  icon: Icons.title,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller:
                      _descripcionController,
                  label: 'Descripción',
                  icon: Icons.description,
                  maxLines: 4,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _generoController,
                  label: 'Género',
                  icon: Icons.category,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _duracionController,
                  label:
                      'Duración, por ejemplo: 2 h 30 min',
                  icon: Icons.timer,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _trailerController,
                  label:
                      'Enlace del tráiler de YouTube',
                  hint:
                      'https://www.youtube.com/watch?v=...',
                  icon: Icons.play_circle_outline,
                  keyboardType: TextInputType.url,
                  validator: _youtubeValidator,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller:
                      _miniaturaController,
                  label:
                      'URL de la imagen o miniatura',
                  hint:
                      'https://image.tmdb.org/...',
                  icon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  validator: _imageUrlValidator,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 20),

                _buildImagePreview(),

                const SizedBox(height: 25),

                if (_isUploading) ...[
                  const LinearProgressIndicator(
                    color: Colors.red,
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _uploadMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                ElevatedButton.icon(
                  onPressed: _isUploading
                      ? null
                      : _uploadVideo,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                  label: Text(
                    _isUploading
                        ? 'GUARDANDO...'
                        : 'GUARDAR PELÍCULA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor:
                        Colors.red.withOpacity(0.5),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final String imageUrl =
        _miniaturaController.text.trim();

    if (imageUrl.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: Colors.white38,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                'Aquí aparecerá la imagen',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            height: 250,
            color: const Color(0xFF1A1A2E),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          );
        },
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            height: 250,
            color: const Color(0xFF1A1A2E),
            child: const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No se pudo cargar la imagen',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: Colors.white70,
        ),
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.red,
        ),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white38,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.orange,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.orange,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }
}