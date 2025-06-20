import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/providers/lesson_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoActivityWidget extends StatefulWidget {
  final Map<String, dynamic> contenido;

  const VideoActivityWidget({super.key, required this.contenido});

  @override
  State<VideoActivityWidget> createState() => _VideoActivityWidgetState();
}

class _VideoActivityWidgetState extends State<VideoActivityWidget> {
  late YoutubePlayerController _controller;
  String? _selectedOption; // Para guardar la opción que el usuario selecciona

  @override
  void initState() {
    super.initState();
    final String videoId = widget.contenido['id_video_youtube'] ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String descripcion = widget.contenido['descripcion'] ?? 'Mira el video y responde.';
    final String pregunta = widget.contenido['pregunta'] ?? '¿Cuál es la respuesta correcta?';
    final List<String> opciones = List<String>.from(widget.contenido['opciones'] ?? []);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título y Descripción
          const Text('Video Inversivo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(descripcion, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 20),

          // Reproductor de YouTube con bordes redondeados
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            ),
          ),
          const SizedBox(height: 24),

          // Pregunta
          Text(pregunta, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          // Opciones de respuesta
          ...opciones.map((opcion) {
            bool isSelected = _selectedOption == opcion;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedOption = opcion;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.green.withOpacity(0.2) : Colors.transparent,
                  side: BorderSide(color: isSelected ? Colors.green.shade700 : Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  opcion,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 24),
          // Botón de Verificar que vimos en tu prototipo
          // La lógica de verificación la añadiremos en el siguiente paso
          ElevatedButton(
            // El botón estará deshabilitado si no se ha seleccionado ninguna opción
            onPressed: _selectedOption == null ? null : () {
              // Llamamos al método del provider para verificar la respuesta
              Provider.of<LessonProvider>(context, listen: false)
                  .checkVideoAnswer(_selectedOption);
            },
            child: const Text('VERIFICAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            ),
          )
        ],
      ),
    );
  }
}