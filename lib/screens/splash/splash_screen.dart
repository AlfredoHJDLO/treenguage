import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treenguage/api/auth_service.dart';
import 'package:treenguage/providers/dashboard_provider.dart';

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

  // En lib/screens/splash/splash_screen.dart
Future<void> _checkLoginStatus() async {
  await Future.delayed(const Duration(seconds: 1)); 

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');

  if (!mounted) return;

  if (token != null) {
    print("Token encontrado. Verificando perfil de usuario...");
    try {
      // Le pedimos al DashboardProvider que cargue TODOS los datos iniciales
      final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
      dashboardProvider.clearData();
      await dashboardProvider.fetchDashboardData();

      if (!mounted) return;

      // Ahora que los datos están cargados, revisamos el perfil
      final userProfile = dashboardProvider.userProfile;
      final idIdioma = userProfile?['id_idioma_actual'];

      if (idIdioma != null) {
        print("Usuario tiene idioma. Navegando a /home...");
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        print("Usuario NO tiene idioma. Navegando a /select-language...");
        Navigator.of(context).pushReplacementNamed('/select-language');
      }
    } catch (e) {
      print("Token inválido o error de red: $e. Navegando a /login...");
      Navigator.of(context).pushReplacementNamed('/login');
    }
  } else {
    print("No hay token. Navegando a /login...");
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