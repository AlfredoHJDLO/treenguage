// lib/api/progress_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  final String _baseUrl =
      "https://fastapi-idiomas.onrender.com"; // Tu URL del backend

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

  Future<void> actualizarProgresoVocabulario(int palabraId) async {
    final token =
        await _getToken(); // Reutilizamos el método para obtener el token
    final url = Uri.parse('$_baseUrl/progreso/vocabulario');

    // El backend espera el id de la palabra, y podemos definir el nuevo estado.
    // Lo marcaremos como 'APRENDIENDO' con 1 acierto por haberla visto.
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_palabra': palabraId,
        'aciertos': 1,
        'fallos': 0,
        'estado_aprendizaje': 'APRENDIENDO',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el progreso del vocabulario');
    }
    // Si todo va bien, no necesitamos hacer nada más.
  }

  // Método helper para obtener el token (si no lo tienes ya)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> marcarLeccionComoCompletada(int leccionId) async {
    final token = await _getToken();
    // El endpoint que ya existe en routers/progreso.py
    final url = Uri.parse('$_baseUrl/progreso/lecciones/$leccionId');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Le decimos al backend que el nuevo estado es "COMPLETADA"
      body: json.encode({
        'estado': 'COMPLETADA',
        // Podemos poner cualquier valor aquí, el backend lo actualizará
        'ultima_actividad': 999,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al marcar la lección como completada');
    }
  }
}
