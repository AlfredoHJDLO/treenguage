// lib/screens/auth/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/api/user_service.dart';
import 'package:treenguage/providers/dashboard_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos el DashboardProvider porque ya tiene la lista de idiomas cargada
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final userService = UserService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecciona un Idioma"),
        automaticallyImplyLeading: false, // Oculta el botón de "atrás"
      ),
      body: ListView.builder(
        itemCount: dashboardProvider.idiomas.length,
        itemBuilder: (context, index) {
          final idioma = dashboardProvider.idiomas[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(idioma.urlBandera ?? ''),
                child: idioma.urlBandera == null ? const Icon(Icons.language) : null,
              ),
              title: Text(idioma.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                try {
                  // 1. Llama al servicio para actualizar el idioma en el backend
                  await userService.selectLanguage(idioma.id);
                  // 2. Refresca todos los datos del dashboard
                  await dashboardProvider.fetchDashboardData();
                  
                  if (!context.mounted) return;
                  // 3. Navega a la pantalla principal
                  Navigator.of(context).pushReplacementNamed('/home');

                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'))
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}