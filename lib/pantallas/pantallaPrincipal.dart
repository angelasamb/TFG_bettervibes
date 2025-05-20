import 'package:flutter/material.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Principal'),
        backgroundColor: Colors.gamaColores.shade400, // usa tu color personalizado
      ),
      body: Center(
        child: Text(
          'Pantalla Principal',
          style: TextStyle(
            fontSize: 24,
            color: Colors.gamaColores.shade400, // mismo color para mantener coherencia
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
