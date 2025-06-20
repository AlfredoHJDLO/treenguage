// lib/api/course_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treenguage/models/idioma_model.dart';
import 'package:treenguage/models/leccion_model.dart';
import 'package:treenguage/models/nivel_model.dart';

class CourseService {
  final String _baseUrl = "http://192.168.137.1:8000";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Método para obtener todos los niveles
  Future<List<Nivel>> getNiveles() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/niveles');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Nivel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los niveles');
    }
  }

  // Método para obtener todas las lecciones
  Future<List<Leccion>> getLecciones() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/lecciones');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Leccion.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener las lecciones');
    }
  }
  // En lib/api/course_service.dart

  // ... (después del método getLecciones)

  // Método para obtener las actividades de UNA lección
  Future<List<dynamic>> getActividades(int leccionId) async {
    final token = await _getToken();
    // El endpoint que tu compañero creó en routers/leccion.py
    final url = Uri.parse('$_baseUrl/lecciones/actividades/$leccionId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // La respuesta es una lista de objetos de actividad
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener las actividades de la lección');
    }
  }

  Future<List<Idioma>> getIdiomas() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/idiomas'); // Llama al endpoint de idiomas
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Idioma.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los idiomas');
    }
  }
}
