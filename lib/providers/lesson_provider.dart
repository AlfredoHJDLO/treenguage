// lib/providers/lesson_provider.dart
import 'package:flutter/material.dart';
import 'package:treenguage/api/course_service.dart';

class LessonProvider extends ChangeNotifier {
  final CourseService _courseService = CourseService();

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _activities = [];
  int _currentActivityIndex = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get activities => _activities;
  int get currentActivityIndex => _currentActivityIndex;
  dynamic get currentActivity =>
      _activities.isNotEmpty ? _activities[_currentActivityIndex] : null;
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

  void goToNextActivity() {
    if (_currentActivityIndex < _activities.length - 1) {
      _currentActivityIndex++;
      notifyListeners();
    } else {
      // La lección ha terminado
      print("¡Lección completada!");
    }
  }
}
