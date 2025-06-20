// lib/services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text, String languageCode) async {
    // Configura el idioma. Ej: "es-ES", "en-US", "pt-BR"
    await _flutterTts.setLanguage(languageCode);
    // Configura una velocidad de habla normal
    await _flutterTts.setSpeechRate(0.5);
    // Reproduce el texto
    await _flutterTts.speak(text);
  }
  // En lib/services/tts_service.dart
Future<dynamic> getVoices() async {
    return await _flutterTts.getVoices;
}
}