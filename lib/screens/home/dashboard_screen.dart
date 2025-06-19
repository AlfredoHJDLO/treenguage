// lib/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Barra superior transparente para un look moderno
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Hola Eduardo',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            // Círculo para la foto de perfil
            child: CircleAvatar(
              // Aquí iría la imagen del usuario
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
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
              'Estoy aprendiendo: 🇧🇷 Portugués', // Ejemplo
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Tarjeta "Continúa aprendiendo"
            _buildContinueLearningCard(),

            const SizedBox(height: 32),

            // Sección de Niveles
            _buildLevelSection(title: 'Nivel 1 >', isFirstLevel: true),
            const SizedBox(height: 24),
            _buildLevelSection(title: 'Nivel 2 >', isFirstLevel: false),
          ],
        ),
      ),
    );
  }

  // Widget para la tarjeta de continuar
  Widget _buildContinueLearningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/6/62/Praia_de_Copacabana_-_Rio_de_Janeiro%2C_Brasil.jpg'), // Imagen de Río
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3), // Un filtro oscuro para que el texto resalte
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
          const Text(
            'Lección 1.1:\nSaludos y despedidas',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
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

  // Widget para construir una sección de nivel
  Widget _buildLevelSection({required String title, required bool isFirstLevel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLessonCard(
              title: 'Lección 1',
              subtitle: 'Saludos y despedidas',
              icon: isFirstLevel ? Icons.play_arrow : Icons.lock,
              isLocked: !isFirstLevel,
            ),
            const SizedBox(width: 16),
            _buildLessonCard(
              title: 'Lección 2',
              subtitle: 'Con amigos y familia',
              icon: Icons.lock,
              isLocked: true,
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ],
    );
  }

  // Widget para las tarjetas de lección
  Widget _buildLessonCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      required bool isLocked}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[300] : Colors.green[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isLocked ? Colors.grey[600] : Colors.green[800]),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey[600] : Colors.black),
            ),
            Text(
              subtitle,
              style: TextStyle(
                  fontSize: 12,
                  color: isLocked ? Colors.grey[600] : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}