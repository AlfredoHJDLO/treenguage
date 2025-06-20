// lib/api/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String _baseUrl = "https://fastapi-idiomas.onrender.com/"; // Tu IP

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> selectLanguage(int idiomaId) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/users/me/language');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'id_idioma': idiomaId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al seleccionar el idioma');
    }
  }
}
