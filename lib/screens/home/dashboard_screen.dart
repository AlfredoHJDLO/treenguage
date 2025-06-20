// lib/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/models/leccion_model.dart';
import 'package:treenguage/models/nivel_model.dart';
import 'package:treenguage/providers/auth_provider.dart';
import 'package:treenguage/providers/dashboard_provider.dart';
import 'package:treenguage/providers/lesson_provider.dart';
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.isUnauthorized) {
            // Si no está autorizado, cerramos sesión y vamos al login
            Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (Route<dynamic> route) => false,
            );
          }
        });
        // Muestra un indicador de carga mientras se obtienen los datos
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Muestra un error si algo falló
        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }

        // Si no hay datos, muestra un mensaje
        if (provider.estadoActual == null) {
          return const Center(
            child: Text('No se encontraron datos de progreso.'),
          );
        }

        // Una vez que tenemos los datos, construimos la UI
        final leccionActual = provider.estadoActual!['leccion_actual'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // El título y la foto de perfil que ya teníamos
            title: Text(
              'Hola Eduardo',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              // --- AÑADE ESTE BOTÓN ---
              IconButton(
                icon: Icon(Icons.logout, color: Colors.grey[700]),
                onPressed: () async {
                  // Llama al método de logout del AuthProvider
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout();

                  if (!mounted) return;

                  // Navega de vuelta al login y elimina todas las pantallas anteriores del historial
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=12',
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estoy aprendiendo: 🇧🇷 Portugués',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 24),

                if (leccionActual != null)
                  _buildContinueLearningCard(leccionActual)
                else
                  _buildStartLearningCard(),

                const SizedBox(height: 32),

                // --- AQUÍ VIENE LA MAGIA ---
                // Usamos un ListView.builder para crear la lista de niveles dinámicamente
                ListView.builder(
                  shrinkWrap:
                      true, // Importante dentro de un SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Para que no haga scroll por sí mismo
                  itemCount: provider.nivelesDelCurso.length,
                  itemBuilder: (context, index) {
                    final nivel = provider.nivelesDelCurso[index];
                    // Reutilizamos el widget que ya habíamos creado
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _buildLevelSection(nivel: nivel),
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
  Widget _buildContinueLearningCard(Map<String, dynamic> leccion) {
    return Container(
      // ... (mismo estilo que antes)
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage('https://i.imgur.com/kG0j4f6.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Continua aprendiendo:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Usamos el título de la lección que viene del backend
          Text(
            leccion['titulo'] ?? 'Lección sin título',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
              ),
              child: const Text('CONTINUAR'),
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
  Widget _buildLevelSection({required Nivel nivel}) {
    // Aquí podrías añadir lógica para saber si el nivel está bloqueado
    // basado en el progreso del usuario
    bool isLevelUnlocked =
        nivel.numeroNivel == 1; // Ejemplo: solo el nivel 1 está desbloqueado

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${nivel.titulo} >',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 16),
        // Creamos la fila de tarjetas de lección
        Row(
          children: [
            // Mostramos las primeras dos lecciones del nivel
            if (nivel.lecciones.isNotEmpty)
              _buildLessonCard(
                leccion: nivel.lecciones[0],
                isLocked:
                    !isLevelUnlocked, // La primera lección está desbloqueada si el nivel lo está
              ),
            const SizedBox(width: 16),
            if (nivel.lecciones.length > 1)
              _buildLessonCard(
                leccion: nivel.lecciones[1],
                isLocked:
                    true, // La segunda lección siempre está bloqueada en este ejemplo
              ),
            const Spacer(), // Ocupa el espacio restante
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ],
    );
  }

  // Modifica también _buildLessonCard para que acepte un objeto Leccion
  Widget _buildLessonCard({required Leccion leccion, required bool isLocked}) {
    return Expanded(
      child: GestureDetector(
        onTap:
            isLocked
                ? null
                : () {
                  // El `onTap` solo funciona si no está bloqueado
                  // Navegamos a la pantalla de la lección
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChangeNotifierProvider(
                            create:
                                (_) =>
                                    LessonProvider(), // Creamos una nueva instancia del provider
                            child: LessonScreen(
                              leccionId: leccion.id,
                            ), // Le pasamos el ID de la lección
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
            children: [
              Icon(
                isLocked ? Icons.lock : Icons.play_arrow,
                color: isLocked ? Colors.grey[600] : Colors.green[800],
              ),
              const SizedBox(height: 8),
              Text(
                'Lección ${leccion.numeroLeccion}', // Título dinámico
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey[600] : Colors.black,
                ),
              ),
              Text(
                leccion.titulo, // Subtítulo dinámico
                style: TextStyle(
                  fontSize: 12,
                  color: isLocked ? Colors.grey[600] : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
