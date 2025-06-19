import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Espera 2 segundos para mostrar el logo
    await Future.delayed(const Duration(seconds: 2));

    // Revisa si tenemos un token guardado
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (!mounted) return; // Buena práctica para evitar errores si el widget se destruye

    if (token != null) {
      // Si hay un token, el usuario ya ha iniciado sesión.
      // Aquí podrías verificar si el token aún es válido llamando a un endpoint como /users/me
      // Por ahora, lo llevamos directamente a la pantalla principal.
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Si no hay token, lo llevamos a la pantalla de inicio de sesión.
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Un verde muy claro de fondo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aquí pones tu logo. Asumiendo que lo guardaste en assets/images/logo.png
            Image.asset('assets/images/logo.png', width: 150),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.green, // Un color verde para el spinner
            ),
          ],
        ),
      ),
    );
  }
}