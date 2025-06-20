// lib/api/progress_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  final String _baseUrl = "http://192.168.137.1:8000"; // Tu URL del backend

  Future<Map<String, dynamic>> getEstadoActual() async {
    // Primero, obtenemos el token guardado
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No se encontró token de autenticación.');
    }

    // El endpoint del backend para obtener el estado actual
    final url = Uri.parse('$_baseUrl/progreso/estado-actual');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        // ¡Importante! Enviamos el token para autenticar la petición
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Si el error es 401, lanzamos una excepción específica
      throw Exception('Unauthorized');
    } else {
      // Para cualquier otro error, lanzamos la excepción genérica
      throw Exception('Error al obtener el estado del progreso');
    }
  }
}