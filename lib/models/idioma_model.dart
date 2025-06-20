// lib/models/idioma_model.dart
class Idioma {
  final int id;
  final String nombre;
  final String? urlFondoCurso;
  final String? urlBandera;

  Idioma({
    required this.id,
    required this.nombre,
    this.urlFondoCurso,
    this.urlBandera,
  });

  factory Idioma.fromJson(Map<String, dynamic> json) {
    return Idioma(
      id: json['id'],
      nombre: json['nombre'],
      urlFondoCurso: json['url_fondo_curso'],
      urlBandera: json['url_bandera'],
    );
  }
}