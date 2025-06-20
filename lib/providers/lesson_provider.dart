// lib/providers/lesson_provider.dart
import 'package:flutter/material.dart';
import 'package:treenguage/api/course_service.dart';

enum ActivityStatus { initial, correct, incorrect }

class LessonProvider extends ChangeNotifier {
  final CourseService _courseService = CourseService();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _activities = [];
  int _currentActivityIndex = 0;
  
  ActivityStatus _activityStatus = ActivityStatus.initial;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get activities => _activities;
  int get currentActivityIndex => _currentActivityIndex;
  dynamic get currentActivity =>
      _activities.isNotEmpty ? _activities[_currentActivityIndex] : null;
  ActivityStatus get activityStatus => _activityStatus;
  bool get activityRequiresVerification {
    if (currentActivity == null) return false;
    // Solo la actividad de ORACION requiere verificación por ahora
    return currentActivity['tipo'] == 'ORACION';
  }

  // TODO: Añadir lógica para verificar la respuesta y saber si es correcta
  // bool _isAnswerCorrect = false;
  // bool get isAnswerCorrect => _isAnswerCorrect;

  // ...
  Future<void> fetchActivities(int leccionId) async {
    _isLoading = true;
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

  void checkSentenceAnswer(String userAnswer) {
    if (currentActivity == null || currentActivity['tipo'] != 'ORACION') return;

    final String correctAnswer = currentActivity['contenido']['frase_correcta'] ?? '';
    
    // Comparamos en minúsculas y sin espacios extra para ser más flexibles
    if (userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      _activityStatus = ActivityStatus.correct;
    } else {
      _activityStatus = ActivityStatus.incorrect;
    }
    notifyListeners(); // Notificamos a la UI del cambio de estado
  }

  // 5. Modificamos goToNextActivity para resetear el estado
  void goToNextActivity() {
    if (_currentActivityIndex < _activities.length - 1) {
      _currentActivityIndex++;
      _activityStatus = ActivityStatus.initial; // Reseteamos el estado para la nueva actividad
      notifyListeners();
    } else {
      print("¡Lección completada!");
      // TODO: Navegar a una pantalla de felicitaciones
    }
  }

  void checkVideoAnswer(String? selectedOption) {
  if (currentActivity == null || currentActivity['tipo'] != 'VIDEO' || selectedOption == null) {
    // Si no hay opción seleccionada, no hacemos nada o podríamos marcarla como incorrecta
    _activityStatus = ActivityStatus.incorrect;
    notifyListeners();
    return;
  }

  final String correctAnswer = currentActivity['contenido']['respuesta_correcta'] ?? '';
  
  // Comparamos la opción seleccionada con la respuesta correcta
  if (selectedOption.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
    _activityStatus = ActivityStatus.correct;
  } else {
    _activityStatus = ActivityStatus.incorrect;
  }
  notifyListeners(); // Notificamos a la UI del cambio de estado
}
  
}
