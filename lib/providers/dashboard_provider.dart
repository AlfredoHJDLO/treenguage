// lib/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:treenguage/api/auth_service.dart';
import 'package:treenguage/api/course_service.dart';
import 'package:treenguage/api/progress_service.dart';
import 'package:treenguage/models/idioma_model.dart';
import 'package:treenguage/models/nivel_model.dart';

class DashboardProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProgressService _progressService = ProgressService();
  final CourseService _courseService =
      CourseService(); // Añadimos el nuevo servicio

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _estadoActual;
  List<Nivel> _nivelesDelCurso =
      []; // Nuevo estado para la estructura del curso
      List<Idioma> _idiomas = [];
  bool _isUnauthorized = false;
  Map<String, dynamic>? _userProfile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get estadoActual => _estadoActual;
  List<Nivel> get nivelesDelCurso => _nivelesDelCurso; // Getter para la UI
  bool get isUnauthorized => _isUnauthorized;
  List<Idioma> get idiomas => _idiomas;
  Map<String, dynamic>? get userProfile => _userProfile;

  DashboardProvider() {
    //fetchDashboardData();
  }

Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a la UI que muestre el spinner de carga

    try {
      // Paso 1: Obtenemos el perfil del usuario PRIMERO y esperamos a que termine.
      _userProfile = await _authService.getMyProfile();
      if (_userProfile == null) {
        throw Exception("No se pudo cargar el perfil del usuario.");
      }

      // Paso 2: Obtenemos el estado del progreso del usuario.
      _estadoActual = await _progressService.getEstadoActual();
      if (_estadoActual == null) {
        throw Exception("No se pudo cargar el progreso del usuario.");
      }

      // Paso 3: Obtenemos la lista de todos los idiomas disponibles.
      _idiomas = await _courseService.getIdiomas();

      // Paso 4: AHORA que ya tenemos el _userProfile con datos, 
      // construimos la estructura del curso.
      await _fetchAndBuildCourseStructure();

    } catch (e) {
      print("Error en fetchDashboardData: $e");
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners(); // Notifica a la UI que muestre los datos o el error
  }
  // Nuevo método para construir la estructura del curso
  Future<void> _fetchAndBuildCourseStructure() async {
  // Obtenemos el ID del idioma desde el perfil del usuario que ya cargamos
  final int? idIdiomaActual = _userProfile?['id_idioma_actual'];

  // Si el usuario NO tiene un idioma seleccionado, no cargamos ninguna estructura de curso.
  if (idIdiomaActual == null) {
    print("Usuario no tiene idioma seleccionado. No se carga la estructura del curso.");
    _nivelesDelCurso = []; // Dejamos la lista de niveles vacía
    return;
  }

  print("Cargando estructura para el idioma ID: $idIdiomaActual");

  // El resto de la lógica ahora usa el ID real del usuario
  final todosLosNiveles = await _courseService.getNiveles();
  final todasLasLecciones = await _courseService.getLecciones();

  final nivelesFiltrados = todosLosNiveles.where((nivel) => nivel.idIdioma == idIdiomaActual).toList();

  for (var nivel in nivelesFiltrados) {
    nivel.lecciones = todasLasLecciones.where((leccion) => leccion.idNivel == nivel.id).toList();
  }

  _nivelesDelCurso = nivelesFiltrados;
}

void clearData() {
    _isLoading = true;
    _errorMessage = null;
    _estadoActual = null;
    _nivelesDelCurso = [];
    _idiomas = [];
    _userProfile = null;
    _isUnauthorized = false;
    print("DashboardProvider state has been cleared.");
    // No llamamos a notifyListeners() aquí para no causar reconstrucciones innecesarias
    // hasta que se carguen los nuevos datos.
  }
}
