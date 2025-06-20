import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/providers/dashboard_provider.dart';
import 'package:treenguage/providers/lesson_provider.dart';
import 'package:treenguage/screens/lesson/lesson_complete_screen.dart';
import 'package:treenguage/widgets/lesson_activities/vocabulary_activity_widget.dart';
import 'package:treenguage/widgets/lesson_activities/sentence_activity_widget.dart';
import 'package:treenguage/widgets/lesson_activities/video_activity_widget.dart';
import 'package:treenguage/widgets/lesson_activities/voice_activity_widget.dart';

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
          body: Column(
            children: [
              // El Expanded se asegura de que la actividad ocupe todo el espacio disponible
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBody(
                    provider,
                  ), // _buildBody ahora solo devuelve el widget de la actividad
                ),
              ),
              // El banner de retroalimentación
              _buildFeedbackBanner(provider),
            ],
          ), // Usamos un método helper para el cuerpo
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
    return Column(
      children: [
        Expanded(child: _buildActivityWidget(provider.currentActivity)),
        const SizedBox(height: 16),
        // --- Lógica del Botón Siguiente ---
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                provider.activityStatus == ActivityStatus.correct ||
                        !provider.activityRequiresVerification
                    ? () async {
                      final bool leccionCompletada =
                          await provider.goToNextActivity();

                      if (!mounted) return;

                      if (leccionCompletada) {
                        // En lugar de refrescar y volver, ahora navegamos a la pantalla de felicitaciones
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LessonCompleteScreen(),
                          ),
                        );
                      }
                    }
                    : null,
            child: const Text('Siguiente'),
          ),
        ),
      ],
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
        return VideoActivityWidget(contenido: contenido);
      case 'VOZ':
        return VoiceActivityWidget(contenido: contenido);
      default:
        return Center(child: Text('Tipo de actividad desconocido: $tipo'));
    }
  }

  Widget _buildFeedbackBanner(LessonProvider provider) {
    if (provider.activityStatus == ActivityStatus.initial) {
      // Si el estado es inicial, no mostramos nada
      return const SizedBox.shrink();
    }

    final bool esCorrecto = provider.activityStatus == ActivityStatus.correct;
    final String mensaje =
        esCorrecto
            ? "¡Excelente!"
            : "Respuesta incorrecta. ¡Inténtalo de nuevo!";
    final Color colorFondo =
        esCorrecto ? Colors.green.shade700 : Colors.red.shade700;
    final IconData icono = esCorrecto ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.all(16),
      color: colorFondo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: Colors.white),
              const SizedBox(width: 16),
              Text(
                mensaje,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (provider.aiFeedback != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.aiFeedback!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
