// lib/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:treenguage/api/course_service.dart';
import 'package:treenguage/api/progress_service.dart';
import 'package:treenguage/models/nivel_model.dart';

class DashboardProvider extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();
  final CourseService _courseService =
      CourseService(); // Añadimos el nuevo servicio

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _estadoActual;
  List<Nivel> _nivelesDelCurso =
      []; // Nuevo estado para la estructura del curso
  bool _isUnauthorized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get estadoActual => _estadoActual;
  List<Nivel> get nivelesDelCurso => _nivelesDelCurso; // Getter para la UI
  bool get isUnauthorized => _isUnauthorized;

  DashboardProvider() {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _isUnauthorized = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // Pedimos el estado actual y la estructura del curso en paralelo
      final results = await Future.wait([
        _progressService.getEstadoActual(),
        _fetchAndBuildCourseStructure(),
      ]);

      _estadoActual = results[0] as Map<String, dynamic>;
      // El segundo resultado ya está guardado en _nivelesDelCurso
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
        _isUnauthorized = true;
      } else {
        _errorMessage = e.toString();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Nuevo método para construir la estructura del curso
  Future<void> _fetchAndBuildCourseStructure() async {
    // Asumimos por ahora que el idioma es 1 (Portugués)
    const int idIdiomaActual = 1;

    // Obtenemos las listas "planas" de la API
    final todosLosNiveles = await _courseService.getNiveles();
    final todasLasLecciones = await _courseService.getLecciones();

    // Filtramos los niveles que pertenecen al idioma actual
    final nivelesFiltrados =
        todosLosNiveles
            .where((nivel) => nivel.idIdioma == idIdiomaActual)
            .toList();

    // Para cada nivel, encontramos y asignamos sus lecciones
    for (var nivel in nivelesFiltrados) {
      nivel.lecciones =
          todasLasLecciones
              .where((leccion) => leccion.idNivel == nivel.id)
              .toList();
    }

    _nivelesDelCurso = nivelesFiltrados;
  }
}
