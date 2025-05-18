import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PantallaDatosUsuario extends StatelessWidget {
  const PantallaDatosUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/imagenes/fondo1.png", fit: BoxFit.cover),
          ),
          const Center(
            child: Column(

            ),
          )
        ],
      ),
    );
  }
}
