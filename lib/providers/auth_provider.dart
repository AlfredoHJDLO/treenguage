import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treenguage/api/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> loginUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a la UI que estamos cargando

    try {
      final token = await _authService.login(email, password);

      // Guardamos el token de forma segura en el dispositivo
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);

      _isLoading = false;
      notifyListeners(); // Notifica que terminamos de cargar
      return true; // Login exitoso
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners(); // Notifica del error
      return false; // Login fallido
    }
  }

  Future<bool> registerUser({
    required String nombre,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        nombre: nombre,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Registro exitoso
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Registro fallido
    }
  }

  Future<void> logout() async {
  // Borramos el token guardado en el dispositivo
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
  notifyListeners();
}
}