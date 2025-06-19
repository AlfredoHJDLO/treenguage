import 'package:flutter/material.dart';
import 'package:treenguage/screens/auth/login_screen.dart';
import 'package:treenguage/screens/home/home_screen.dart';
import 'package:treenguage/screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treenguages',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Color de fondo general
        fontFamily: 'Roboto', // O la fuente que prefieras
      ),
      // La pantalla inicial de la app
      home: const SplashScreen(),
      // Definimos las rutas para la navegación
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}