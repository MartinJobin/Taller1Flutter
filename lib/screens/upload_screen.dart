import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../services/video_service.dart';
import '../models/video_model.dart';
import '../services/firebase_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  
  File? _videoFile;
  File? _thumbnailFile;
  bool _isUploading = false;
  double _uploadProgress = 0;
  
  final VideoService _videoService = VideoService();

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _videoFile = File(result.files.first.path!);
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    
    if (result != null) {
      setState(() {
        _thumbnailFile = File(result.path);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_videoFile == null) {
      _showMessage('❌ Selecciona un video', Colors.orange);
      return;
    }
    if (_thumbnailFile == null) {
      _showMessage('❌ Selecciona una miniatura', Colors.orange);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final String videoId = const Uuid().v4();
      final String userId = FirebaseService.currentUser!.uid;
      
      // 🔹 Subir video a Storage
      String videoUrl = await _videoService.uploadVideo(
        _videoFile!.path,
        '$videoId.mp4',
      );
      
      // 🔹 Subir miniatura a Storage
      String thumbnailUrl = await _videoService.uploadThumbnail(
        _thumbnailFile!.path,
        '$videoId.jpg',
      );
      
      // 🔹 Guardar datos en Realtime Database
      final video = VideoModel(
        id: videoId,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        urlStorage: videoUrl,
        miniatura: thumbnailUrl,
        duracion: _duracionController.text.trim(),
        genero: _generoController.text.trim(),
        fechaSubida: DateTime.now(),
        usuarioId: userId,
      );
      
      await _videoService.saveVideo(video);
      
      _showMessage(' ¡Video subido exitosamente!', Colors.green);
      
      // Limpiar formulario
      _tituloController.clear();
      _descripcionController.clear();
      _generoController.clear();
      _duracionController.clear();
      setState(() {
        _videoFile = null;
        _thumbnailFile = null;
      });
      
    } catch (e) {
      _showMessage('❌ Error al subir: $e', Colors.red);
    }

    setState(() {
      _isUploading = false;
      _uploadProgress = 0;
    });
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Video', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          
              TextFormField(
                controller: _tituloController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Título del video',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.title, color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 15),

             
              TextFormField(
                controller: _descripcionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.description, color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 15),

         
              TextFormField(
                controller: _generoController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Género',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.category, color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 15),

           
              TextFormField(
                controller: _duracionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Duración (ej: 2:30)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.timer, color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),

          
              _buildFilePicker(
                label: 'Seleccionar Video',
                icon: Icons.video_file,
                file: _videoFile,
                onTap: _pickVideo,
                color: Colors.blue,
              ),
              const SizedBox(height: 10),

         
              _buildFilePicker(
                label: 'Seleccionar Miniatura',
                icon: Icons.image,
                file: _thumbnailFile,
                onTap: _pickThumbnail,
                color: Colors.green,
              ),
              const SizedBox(height: 30),

        
              if (_isUploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[800],
                  color: Colors.red,
                ),
                const SizedBox(height: 10),
                Text(
                  'Subiendo... ${(_uploadProgress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],

         
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SUBIR VIDEO',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker({
    required String label,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[900],
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file != null ? file.path.split('/').last : label,
                style: TextStyle(
                  color: file != null ? Colors.white : Colors.white54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.cloud_upload,
              color: file != null ? Colors.green : color,
            ),
          ],
        ),
      ),
    );
  }
}