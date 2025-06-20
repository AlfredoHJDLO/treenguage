import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de que este import esté

class AuthService {
  // La URL base de tu backend.
  final String _baseUrl = "http://192.168.137.1:8000";

  // --- AÑADE ESTE MÉTODO DE AYUDA ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/token');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['access_token'];
      return token;
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Error al iniciar sesión');
    }
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/users');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'nombre': nombre,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Error al registrar el usuario');
    }
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    // Ahora esta función puede llamar a _getToken sin problemas
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/users/me');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener el perfil del usuario');
    }
  }
}