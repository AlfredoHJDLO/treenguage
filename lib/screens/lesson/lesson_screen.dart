import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/providers/lesson_provider.dart';
import 'package:treenguage/widgets/lesson_activities/vocabulary_activity_widget.dart';
import 'package:treenguage/widgets/lesson_activities/sentence_activity_widget.dart';

class LessonScreen extends StatefulWidget {
  final int leccionId;
  const LessonScreen({super.key, required this.leccionId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para asegurarnos de que el contexto esté disponible.
    // Le pedimos al provider que cargue las actividades para esta lección.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LessonProvider>(
        context,
        listen: false,
      ).fetchActivities(widget.leccionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para que la pantalla se reconstruya con los cambios del provider.
    return Consumer<LessonProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Lección'),
            backgroundColor: Colors.green[700],
            // Añadimos la barra de progreso
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                // El valor va de 0.0 a 1.0
                value:
                    provider.activities.isEmpty
                        ? 0
                        : (provider.currentActivityIndex + 1) /
                            provider.activities.length,
                backgroundColor: Colors.green[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          body: _buildBody(provider), // Usamos un método helper para el cuerpo
        );
      },
    );
  }

  // Método helper para construir el cuerpo de la pantalla
  Widget _buildBody(LessonProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text('Error: ${provider.errorMessage}'));
    }

    if (provider.activities.isEmpty) {
      return const Center(child: Text('No hay actividades en esta lección.'));
    }

    // Si todo está bien, mostramos la actividad actual
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Aquí irá el widget de la actividad actual
          Expanded(child: _buildActivityWidget(provider.currentActivity)),

          // Botón para pasar a la siguiente actividad
          ElevatedButton(
            // Si la actividad no requiere verificación, el botón siempre está activo.
            // Si la requiere, estará desactivado hasta que el usuario responda correctamente
            // (añadiremos la lógica de _isAnswerCorrect más adelante).
            onPressed:
                !provider.activityRequiresVerification
                    ? () => provider.goToNextActivity()
                    : null, // null deshabilita el botón
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityWidget(Map<String, dynamic> activity) {
    final String tipo = activity['tipo'] ?? '';
    final Map<String, dynamic> contenido = activity['contenido'] ?? {};

    switch (tipo) {
      case 'VOCABULARIO':
        return VocabularyActivityWidget(contenido: contenido);
      case 'ORACION':
        // Usamos nuestro nuevo y flamante widget interactivo
        return SentenceActivityWidget(contenido: contenido);
      case 'VIDEO':
        return Center(child: Text('Actividad de Video'));
      case 'VOZ':
        return Center(child: Text('Actividad de Voz'));
      default:
        return Center(child: Text('Tipo de actividad desconocido: $tipo'));
    }
  }
}
