import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/providers/auth_provider.dart';
import 'package:treenguage/screens/auth/login_screen.dart';
import 'package:treenguage/screens/home/home_screen.dart';
import 'package:treenguage/screens/splash/splash_screen.dart';
import 'package:treenguage/screens/auth/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos nuestra app con el ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Treenguages',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF1F8E9),
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}