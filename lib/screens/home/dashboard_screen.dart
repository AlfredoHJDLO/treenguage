// lib/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/models/idioma_model.dart';
import 'package:treenguage/models/leccion_model.dart';
import 'package:treenguage/models/nivel_model.dart';
import 'package:treenguage/providers/auth_provider.dart';
import 'package:treenguage/providers/dashboard_provider.dart';
import 'package:treenguage/providers/lesson_provider.dart';
import 'package:treenguage/screens/auth/language_selection_screen.dart';
import 'package:treenguage/screens/lesson/lesson_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // No es necesario llamar aquí porque el provider lo hace en su constructor
    // Si no lo hiciera, esta sería la forma:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<DashboardProvider>(context, listen: false).fetchDashboardData();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        // 1. Manejo de estados de carga y error (esto está bien)
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text('Error: ${provider.errorMessage}')),
          );
        }
        if (provider.estadoActual == null || provider.userProfile == null) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron datos de progreso.')),
          );
        }

        // 2. Extraemos todos los datos necesarios del provider UNA SOLA VEZ
        final userName = provider.userProfile?['nombre'] ?? 'Usuario';
        final idiomaActualId = provider.userProfile?['id_idioma_actual'];
        final leccionActual = provider.estadoActual!['leccion_actual'];
        final progresoLecciones =
            provider.estadoActual!['progreso_lecciones']
                as Map<String, dynamic>? ??
            {};

        String idiomaNombre = 'un idioma';
        String urlBandera = '';
        String urlFondo =
            'https://i.imgur.com/kG0j4f6.png'; // URL de fondo por defecto

        // 3. Buscamos el objeto del idioma actual para obtener su nombre y URLs
        if (idiomaActualId != null && provider.idiomas.isNotEmpty) {
          try {
            final idiomaActual = provider.idiomas.firstWhere(
              (idioma) => idioma.id == idiomaActualId,
            );
            idiomaNombre = idiomaActual.nombre;
            urlBandera = idiomaActual.urlBandera ?? '';
            urlFondo = idiomaActual.urlFondoCurso ?? urlFondo;
          } catch (e) {
            print(
              "Error: No se encontró el idioma con ID $idiomaActualId en la lista de idiomas del provider.",
            );
          }
        }

        // 4. Construimos el Scaffold con los datos ya procesados
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Hola, $userName',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap:
                      () => Navigator.of(context).pushNamed('/select-language'),
                  child: CircleAvatar(
                    backgroundImage:
                        urlBandera.isNotEmpty ? NetworkImage(urlBandera) : null,
                    child:
                        urlBandera.isEmpty ? const Icon(Icons.language) : null,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.grey[700]),
                tooltip: 'Cerrar Sesión',
                onPressed: () async {
                  // 1. Llama al método de logout del AuthProvider
                  Provider.of<DashboardProvider>(
                    context,
                    listen: false,
                  ).clearData();

                  // 2. Limpiamos el estado de autenticación (borramos el token)
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout();

                  if (!context.mounted) return;

                  // 3. Navegamos al login
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estoy aprendiendo: $idiomaNombre',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 24),

                if (leccionActual != null)
                  _buildContinueLearningCard(leccionActual, urlFondo)
                else
                  _buildStartLearningCard(),

                const SizedBox(height: 32),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.nivelesDelCurso.length,
                  itemBuilder: (context, nivelIndex) {
                    final nivel = provider.nivelesDelCurso[nivelIndex];
                    bool isLevelUnlocked =
                        (nivel.numeroNivel ==
                            1); // El nivel 1 siempre está desbloqueado

                    if (!isLevelUnlocked && nivelIndex > 0) {
                      final nivelAnterior =
                          provider.nivelesDelCurso[nivelIndex - 1];
                      if (nivelAnterior.lecciones.isNotEmpty) {
                        final ultimaLeccionAnteriorId =
                            nivelAnterior.lecciones.last.id;
                        if (progresoLecciones[ultimaLeccionAnteriorId
                                .toString()] ==
                            'COMPLETADA') {
                          isLevelUnlocked = true;
                        }
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _buildLevelSection(
                        nivel: nivel,
                        progresoLecciones: progresoLecciones,
                        isLevelUnlocked: isLevelUnlocked,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET DINÁMICO ---
  // En lib/screens/home/dashboard_screen.dart

  Widget _buildContinueLearningCard(
    Map<String, dynamic> leccion,
    String backgroundUrl,
  ) {
    return ClipRRect(
      // Usamos ClipRRect para que la imagen no se salga de los bordes redondeados
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        // Stack nos permite poner widgets uno encima de otro
        children: [
          // --- Capa 1: La Imagen de Fondo Rotada ---
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: 0, // Gira la imagen 180 grados (2 * 90 grados)
              child: Image.network(backgroundUrl, fit: BoxFit.cover),
            ),
          ),

          // --- Capa 2: Un filtro oscuro para que el texto resalte ---
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
            ),
          ),

          // --- Capa 3: El Contenido de la Tarjeta ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continua aprendiendo:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  leccion['titulo'] ?? 'Lección sin título',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica de navegación
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                    ),
                    child: const Text('CONTINUAR'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget de fallback si no hay lección en progreso
  Widget _buildStartLearningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "¡Es hora de empezar!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: Text("Comenzar Nivel 1")),
        ],
      ),
    );
  }

  // Widget para construir una sección de nivel
  // Modifica este método en dashboard_screen.dart
  Widget _buildLevelSection({
    required Nivel nivel,
    required Map<String, dynamic> progresoLecciones,
    required bool isLevelUnlocked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${nivel.titulo} >',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isLevelUnlocked ? Colors.black : Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nivel.lecciones.length,
            itemBuilder: (context, index) {
              final leccion = nivel.lecciones[index];
              bool isLessonLocked = true;

              if (isLevelUnlocked) {
                if (index == 0) {
                  isLessonLocked = false;
                } else {
                  final leccionAnterior = nivel.lecciones[index - 1];
                  final estadoAnterior =
                      progresoLecciones[leccionAnterior.id.toString()];
                  isLessonLocked = estadoAnterior != 'COMPLETADA';
                }
              }

              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 16.0),
                child: _buildLessonCard(
                  leccion: leccion,
                  isLocked: isLessonLocked,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Modifica también _buildLessonCard para que acepte un objeto Leccion
  Widget _buildLessonCard({required Leccion leccion, required bool isLocked}) {
    // Ya no necesitamos Expanded aquí porque el ListView maneja el tamaño
    return GestureDetector(
      onTap:
          isLocked
              ? null
              : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangeNotifierProvider(
                          create: (_) => LessonProvider(),
                          child: LessonScreen(leccionId: leccion.id),
                        ),
                  ),
                );
              },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[300] : Colors.green[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              isLocked ? Icons.lock : Icons.play_arrow,
              color: isLocked ? Colors.grey[600] : Colors.green[800],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lección ${leccion.numeroLeccion}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey[600] : Colors.black,
                  ),
                ),
                Text(
                  leccion.titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLocked ? Colors.grey[600] : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
