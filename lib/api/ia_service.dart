// lib/api/ia_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IaService {
  final String _baseUrl =
      "https://fastapi-idiomas.onrender.com"; // Tu IP local

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String> getErrorExplanation({
    required String userAnswer,
    required String correctAnswer,
    required String languageName,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/ia/explicar-error');

    // Creamos un texto descriptivo para que la IA tenga más contexto
    final errorDescription =
        "El usuario está aprendiendo $languageName. La respuesta correcta era '$correctAnswer', pero el usuario escribió '$userAnswer'.";

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'error_usuario': errorDescription,
        'idioma':
            languageName, // Le decimos a la IA en qué idioma dar la explicación
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['explicacion'] ?? 'No se pudo obtener una explicación.';
    } else {
      throw Exception('Error al obtener la explicación de la IA');
    }
  }
}
