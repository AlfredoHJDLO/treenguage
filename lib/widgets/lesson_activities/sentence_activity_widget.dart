// lib/widgets/lesson_activities/sentence_activity_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treenguage/providers/lesson_provider.dart';

class SentenceActivityWidget extends StatefulWidget {
  final Map<String, dynamic> contenido;

  const SentenceActivityWidget({super.key, required this.contenido});

  @override
  State<SentenceActivityWidget> createState() => _SentenceActivityWidgetState();
}

class _SentenceActivityWidgetState extends State<SentenceActivityWidget> {
  // Lista de palabras que el usuario ha seleccionado para su respuesta
  List<String> _respuestaUsuario = [];
  // Lista de palabras disponibles en el banco
  late List<String> _bancoPalabras;

  @override
  void initState() {
    super.initState();
    // Inicializamos el banco de palabras y lo desordenamos para que no aparezca en orden
    _bancoPalabras = List<String>.from(widget.contenido['banco_palabras'] ?? [])
      ..shuffle();
  }

  // Mueve una palabra del banco a la respuesta del usuario
  void _seleccionarPalabra(String palabra) {
    setState(() {
      _respuestaUsuario.add(palabra);
      _bancoPalabras.remove(palabra);
    });
  }

  // Mueve una palabra de la respuesta de vuelta al banco
  void _deseleccionarPalabra(String palabra, int index) {
    setState(() {
      _respuestaUsuario.removeAt(index);
      _bancoPalabras.add(palabra);
      // Opcional: desordenar de nuevo para que no sea tan obvio dónde estaba
      _bancoPalabras.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    // La frase correcta, la usaremos para verificar después
    final String fraseCorrecta = widget.contenido['frase_correcta'] ?? 'N/A';
    final String fraseOrigen = widget.contenido['frase_origen'] ?? 'Traduce la oración';

    return Column(
      children: [
        // Instrucción
        const Text(
        'Traduce la siguiente frase:',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
      const SizedBox(height: 8),
      Text(
        fraseOrigen, // <--- La mostramos aquí
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
        // Área donde el usuario construye su respuesta
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: List.generate(_respuestaUsuario.length, (index) {
              return ActionChip(
                label: Text(_respuestaUsuario[index]),
                onPressed: () => _deseleccionarPalabra(_respuestaUsuario[index], index),
              );
            }),
          ),
        ),
        const SizedBox(height: 40),

        // Banco de palabras disponibles
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 4.0,
            children: _bancoPalabras.map((palabra) {
              return ElevatedButton(
                onPressed: () => _seleccionarPalabra(palabra),
                child: Text(palabra),
              );
            }).toList(),
          ),
        ),
        
        // Botón para verificar la respuesta (la lógica de verificación la pondremos en el provider)
        ElevatedButton(
          onPressed: () {
            // Unimos las palabras seleccionadas para formar la respuesta
            String respuesta = _respuestaUsuario.join(' ');
            
            // Llamamos al método del provider que ya existe para verificar
            Provider.of<LessonProvider>(context, listen: false)
                .checkSentenceAnswer(respuesta);
          },
          child: const Text('Verificar'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}