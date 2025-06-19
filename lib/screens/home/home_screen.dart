// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:treenguage/screens/home/dashboard_screen.dart';
import 'package:treenguage/screens/home/vocabulario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Controla la pestaña seleccionada

  // Lista de widgets que se mostrarán en cada pestaña
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    VocabularioScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            // El ícono "Aa" de tu prototipo se parece al de "spellcheck"
            icon: Icon(Icons.spellcheck),
            label: 'Vocabulario',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800], // Color para el ítem seleccionado
        onTap: _onItemTapped,
      ),
    );
  }
}