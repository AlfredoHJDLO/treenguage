// lib/models/nivel_model.dart
import 'package:treenguage/models/leccion_model.dart';

class Nivel {
  final int id;
  final int idIdioma;
  final int numeroNivel;
  final String titulo;
  final String? descripcion;
  List<Leccion> lecciones; // Una lista para guardar sus lecciones

  Nivel({
    required this.id,
    required this.idIdioma,
    required this.numeroNivel,
    required this.titulo,
    this.descripcion,
    this.lecciones = const [], // Por defecto, la lista está vacía
  });

  factory Nivel.fromJson(Map<String, dynamic> json) {
    return Nivel(
      id: json['id'],
      idIdioma: json['id_idioma'],
      numeroNivel: json['numero_nivel'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
    );
  }
}