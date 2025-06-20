// lib/models/leccion_model.dart
class Leccion {
  final int id;
  final int idNivel;
  final int numeroLeccion;
  final String titulo;
  final String? descripcion;

  Leccion({
    required this.id,
    required this.idNivel,
    required this.numeroLeccion,
    required this.titulo,
    this.descripcion,
  });

  factory Leccion.fromJson(Map<String, dynamic> json) {
    return Leccion(
      id: json['id'],
      idNivel: json['id_nivel'],
      numeroLeccion: json['numero_leccion'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
    );
  }
}