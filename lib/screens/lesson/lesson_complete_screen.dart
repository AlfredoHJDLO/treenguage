// lib/screens/lesson/lesson_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/providers/dashboard_provider.dart';

class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events, // Un ícono de trofeo
                color: Colors.yellow,
                size: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Lección Completada!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Excelente trabajo! Sigue así para dominar un nuevo idioma.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Refrescamos los datos del dashboard y volvemos a la pantalla principal
                    await Provider.of<DashboardProvider>(context, listen: false)
                        .fetchDashboardData();
                    
                    if (!context.mounted) return;

                    // Navegamos al home y eliminamos todas las pantallas anteriores
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  child: const Text('CONTINUAR'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}