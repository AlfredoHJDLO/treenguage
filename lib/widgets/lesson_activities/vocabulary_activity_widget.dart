// lib/widgets/lesson_activities/vocabulary_activity_widget.dart
import 'package:flutter/material.dart';
import 'package:treenguage/services/tts_service.dart'; // Importamos nuestro servicio

class VocabularyActivityWidget extends StatelessWidget {
  final Map<String, dynamic> contenido;
  final TtsService _ttsService = TtsService(); // Creamos una instancia del servicio

  VocabularyActivityWidget({super.key, required this.contenido});

  @override
  Widget build(BuildContext context) {
    final String palabra = contenido['palabra'] ?? 'N/A';
    final String traduccion = contenido['traduccion'] ?? 'N/A';

    return Card(
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aprende esta palabra:',
              style: TextStyle(color: Colors.grey[600], fontSize: 20),
            ),
            const SizedBox(height: 30),

            // Palabra en el idioma a aprender
            Text(
              palabra,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            // Botón para escuchar la pronunciación
            IconButton(
              icon: const Icon(Icons.volume_up),
              iconSize: 40,
              color: Colors.green[700],
              onPressed: () {
                // Llamamos al servicio para que hable
                // TODO: El código de idioma debe ser dinámico en el futuro
                _ttsService.speak(palabra, 'pt-BR');
              },
            ),
            const SizedBox(height: 20),

            // Traducción
            Text(
              traduccion,
              style: TextStyle(fontSize: 28, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}