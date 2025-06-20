// lib/providers/lesson_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treenguage/api/course_service.dart';
import 'package:treenguage/api/progress_service.dart';
import 'package:treenguage/api/ia_service.dart';

enum ActivityStatus { initial, correct, incorrect }

class LessonProvider extends ChangeNotifier {
  final IaService _iaService = IaService();
  final CourseService _courseService = CourseService();
  final ProgressService _progressService = ProgressService();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _activities = [];
  int _currentActivityIndex = 0;
  String? _aiFeedback;

  ActivityStatus _activityStatus = ActivityStatus.initial;
  int? _currentLessonId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get activities => _activities;
  int get currentActivityIndex => _currentActivityIndex;
  dynamic get currentActivity =>
      _activities.isNotEmpty ? _activities[_currentActivityIndex] : null;
  ActivityStatus get activityStatus => _activityStatus;
  String? get aiFeedback => _aiFeedback;

  bool get activityRequiresVerification {
    if (currentActivity == null) return false;

    final tipo = currentActivity['tipo'];
    // Ahora, la verificación es necesaria para estos tres tipos
    return tipo == 'ORACION' || tipo == 'VIDEO' || tipo == 'VOZ';
  }

  // TODO: Añadir lógica para verificar la respuesta y saber si es correcta
  // bool _isAnswerCorrect = false;
  // bool get isAnswerCorrect => _isAnswerCorrect;

  // ...
  Future<void> fetchActivities(int leccionId) async {
    _isLoading = true;
    _currentLessonId = leccionId; // <-- Guardamos el ID de la lección aquí
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _courseService.getActividades(leccionId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void checkSentenceAnswer(String userAnswer) async {
    if (currentActivity == null || currentActivity['tipo'] != 'ORACION') return;

    final String correctAnswer =
        currentActivity['contenido']['frase_correcta'] ?? '';

    _aiFeedback = null;
    // Comparamos en minúsculas y sin espacios extra para ser más flexibles
    if (userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      _activityStatus = ActivityStatus.correct;
    } else {
      _activityStatus = ActivityStatus.incorrect;
      try {
        // Necesitamos el nombre del idioma, que por ahora no tenemos aquí.
        // Lo pondremos como "Portugués" de forma fija por ahora.
        _aiFeedback = await _iaService.getErrorExplanation(
          userAnswer: userAnswer,
          correctAnswer: correctAnswer,
          languageName: "portugués",
        );
      } catch (e) {
        _aiFeedback = "No se pudo cargar la sugerencia.";
      }
    }
    notifyListeners(); // Notificamos a la UI del cambio de estado
  }

  // 5. Modificamos goToNextActivity para resetear el estado
  Future<bool> goToNextActivity() async {
    if (_currentActivityIndex < _activities.length - 1) {
      _currentActivityIndex++;
      _activityStatus = ActivityStatus.initial;
      _aiFeedback = null; // <-- Limpiamos la retroalimentación
      notifyListeners();
      return false;
    } else {
      print("¡Lección completada!");
      if (_currentLessonId != null) {
        // Usamos el ID que guardamos al principio, es más seguro
        await _progressService.marcarLeccionComoCompletada(_currentLessonId!);
      }
      return true; // ¡Sí, ha terminado!
    }
  }

  void checkVideoAnswer(String? selectedOption) {
    if (currentActivity == null ||
        currentActivity['tipo'] != 'VIDEO' ||
        selectedOption == null) {
      // Si no hay opción seleccionada, no hacemos nada o podríamos marcarla como incorrecta
      _activityStatus = ActivityStatus.incorrect;
      notifyListeners();
      return;
    }

    final String correctAnswer =
        currentActivity['contenido']['respuesta_correcta'] ?? '';

    // Comparamos la opción seleccionada con la respuesta correcta
    if (selectedOption.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase()) {
      _activityStatus = ActivityStatus.correct;
    } else {
      _activityStatus = ActivityStatus.incorrect;
    }
    notifyListeners(); // Notificamos a la UI del cambio de estado
  }

  Future<void> checkVoiceAnswer(
    int actividadVozId,
    String transcripcion,
  ) async {
    // TODO: Mover esta lógica a un servicio (ej. VerificationService)
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');
    const String baseUrl = "https://fastapi-idiomas.onrender.com";
    final url = Uri.parse('$baseUrl/ia/verificar-voz');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id_actividad_voz': actividadVozId,
          'transcripcion_usuario': transcripcion,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool esCorrecta = data['es_correcta'] ?? false;
        _activityStatus =
            esCorrecta ? ActivityStatus.correct : ActivityStatus.incorrect;
      } else {
        _activityStatus = ActivityStatus.incorrect;
      }
    } catch (e) {
      _activityStatus = ActivityStatus.incorrect;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> registrarPalabraVista(int palabraId) async {
    try {
      // Llama al servicio para registrar el progreso.
      await _progressService.actualizarProgresoVocabulario(palabraId);
      print('Progreso para la palabra $palabraId actualizado con éxito.');
    } catch (e) {
      // Si falla, podemos imprimir un error, pero no es necesario detener la app.
      print('Fallo al actualizar el progreso del vocabulario: $e');
    }
  }
}
