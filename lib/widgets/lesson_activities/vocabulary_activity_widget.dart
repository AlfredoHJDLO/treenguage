import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:treenguage/providers/lesson_provider.dart'; // Importamos el paquete http

class VocabularyActivityWidget extends StatefulWidget {
  final Map<String, dynamic> contenido;

  VocabularyActivityWidget({super.key, required this.contenido});

  @override
  State<VocabularyActivityWidget> createState() => _VocabularyActivityWidgetState();
}

class _VocabularyActivityWidgetState extends State<VocabularyActivityWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // La llamada en initState es correcta para la *primera vez* que el widget aparece.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registrarProgreso();
    });
  }

  // --- AÑADIMOS ESTE NUEVO MÉTODO ---
  @override
  void didUpdateWidget(covariant VocabularyActivityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Comparamos el contenido del widget anterior con el nuevo.
    // Si el ID de la palabra es diferente, significa que es una nueva actividad de vocabulario.
    if (widget.contenido['id'] != oldWidget.contenido['id']) {
      print("Widget actualizado con una nueva palabra, registrando progreso...");
      _registrarProgreso();
    }
  }

  // Creamos una función helper para no repetir código
  void _registrarProgreso() {
    final int? palabraId = widget.contenido['id'];
    if (palabraId != null) {
      Provider.of<LessonProvider>(context, listen: false)
          .registrarPalabraVista(palabraId);
    }
  }

  // La nueva función que primero descarga y luego reproduce
  Future<void> _playAudio(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Guardamos una referencia

    try {
      final int? palabraId = widget.contenido['id'];

      if (palabraId == null) {
        throw Exception("No se encontró el ID de la palabra.");
      }
      
      final String baseUrl = "http://192.168.137.1:8000"; // Tu IP local
      final String url = "$baseUrl/audio/vocabulario/$palabraId";
      
      print("1. Descargando audio desde: $url");

      // PASO 1: Descargar el audio usando el paquete http
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print("2. Descarga completa. Reproduciendo bytes de audio...");
        
        // PASO 2: Reproducir los bytes descargados
        // Usamos BytesSource en lugar de UrlSource
        await _audioPlayer.play(BytesSource(response.bodyBytes));
        print("3. La reproducción se inició correctamente.");

      } else {
        // Si el backend devuelve un error
        throw Exception("El servidor devolvió un error: ${response.statusCode}");
      }
    } catch (e) {
      print("¡ERROR! Excepción atrapada: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo reproducir el audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String palabra = widget.contenido['palabra'] ?? 'N/A';
    final String traduccion = widget.contenido['traduccion'] ?? 'N/A';

    return Card(
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Aprende esta palabra:', style: TextStyle(color: Colors.grey[600], fontSize: 20)),
            const SizedBox(height: 30),
            Text(palabra, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.volume_up),
              iconSize: 40,
              color: Colors.green[700],
              onPressed: () => _playAudio(context),
            ),
            const SizedBox(height: 20),
            Text(traduccion, style: TextStyle(fontSize: 28, color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}