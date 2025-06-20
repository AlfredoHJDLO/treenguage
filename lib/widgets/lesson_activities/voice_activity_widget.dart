import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treenguage/providers/lesson_provider.dart';

class VoiceActivityWidget extends StatefulWidget {
  final Map<String, dynamic> contenido;
  const VoiceActivityWidget({super.key, required this.contenido});

  @override
  State<VoiceActivityWidget> createState() => _VoiceActivityWidgetState();
}

class _VoiceActivityWidgetState extends State<VoiceActivityWidget> {
  // --- Variables de Estado ---
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  // Usaremos este nombre de variable para ser consistentes
  String _transcribedText = '';
  bool _isProcessing = false;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    // Si ya se está procesando, no hacemos nada
    if (_isProcessing) return;

    if (_isRecording) {
      await _stopRecordingAndTranscribe();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/audio_record.wav';

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _audioRecorder.start(config, path: path);
      setState(() {
        _isRecording = true;
        _transcribedText = 'Escuchando...';
      });
    }
  }

  Future<void> _stopRecordingAndTranscribe() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _transcribedText = 'Procesando audio...';
    });

    if (path != null) {
      try {
        final transcription = await _uploadAudio(path);
        setState(() {
          _transcribedText =
              transcription.isEmpty
                  ? "No se pudo reconocer la voz."
                  : transcription;
        });
      } catch (e) {
        setState(() {
          _transcribedText = "Error al transcribir: $e";
        });
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<String> _uploadAudio(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');
    const String baseUrl = "https://fastapi-idiomas.onrender.com/"; // Tu IP
    final url = Uri.parse('$baseUrl/ia/transcribir-audio');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'audio_file',
        filePath,
        contentType: MediaType('audio', 'wav'),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody)['transcripcion'];
    } else {
      throw Exception(
        'Error del servidor: ${response.statusCode} - $responseBody',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fraseARepetir = widget.contenido['frase_a_repetir'] ?? 'N/A';
    final int? actividadVozId = widget.contenido['id'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Text(
              'Repite la siguiente frase:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              fraseARepetir,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        Expanded(
          child: Center(
            child: Text(
              _transcribedText.isEmpty
                  ? 'Toca el micrófono para empezar a hablar...'
                  : _transcribedText,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        Column(
          children: [
            _isProcessing
                ? const CircularProgressIndicator()
                : FloatingActionButton(
                  onPressed: _toggleRecording,
                  backgroundColor:
                      _isRecording ? Colors.red : Colors.green.shade700,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (_transcribedText.isEmpty || _isProcessing || _isRecording)
                      ? null
                      : () {
                        if (actividadVozId != null) {
                          Provider.of<LessonProvider>(
                            context,
                            listen: false,
                          ).checkVoiceAnswer(actividadVozId, _transcribedText);
                        }
                      },
              child: const Text('Verificar'),
            ),
          ],
        ),
      ],
    );
  }
}
