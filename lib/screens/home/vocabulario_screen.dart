import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/providers/dashboard_provider.dart';
import 'package:treenguage/models/leccion_model.dart';
import 'package:treenguage/models/nivel_model.dart';

class VocabularioScreen extends StatelessWidget {
  const VocabularioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Vocabulario'),
        backgroundColor: Colors.green[700],
      ),
      // Usamos un Consumer para acceder a los datos que ya cargó el DashboardProvider
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          // Obtenemos el progreso y la estructura del curso
          final vocabularioProgreso = provider.estadoActual?['vocabulario_aprendido'] as List<dynamic>? ?? [];
          final todosLosNiveles = provider.nivelesDelCurso;

          if (vocabularioProgreso.isEmpty) {
            return const Center(
              child: Text('Aún no has aprendido ninguna palabra.\n¡Empieza una lección!', textAlign: TextAlign.center),
            );
          }
          
          // Lógica para encontrar los detalles de cada palabra
          final Map<int, Map<String, String>> detallesVocabulario = {};
          for (Nivel nivel in todosLosNiveles) {
            for (Leccion leccion in nivel.lecciones) {
              // Necesitamos una forma de acceder a las actividades aquí.
              // Por ahora, vamos a simularlo. En un paso futuro, mejoraremos el modelo.
            }
          }
          // Este es un placeholder. La lógica real es más compleja, la haremos después.


          return ListView.builder(
            itemCount: vocabularioProgreso.length,
            itemBuilder: (context, index) {
              final progreso = vocabularioProgreso[index];
              final int palabraId = progreso['id_palabra'];
              final String estado = progreso['estado_aprendizaje'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    'Palabra con ID: $palabraId', // Placeholder
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Traducción...'), // Placeholder
                  trailing: Chip(
                    label: Text(estado),
                    backgroundColor: _getColorForEstado(estado),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Método helper para dar color al estado de la palabra
  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'DOMINADA':
        return Colors.green.shade100;
      case 'APRENDIENDO':
        return Colors.yellow.shade100;
      case 'NUEVA':
      default:
        return Colors.grey.shade200;
    }
  }
}