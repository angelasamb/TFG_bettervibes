import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PantallaDatosUsuario extends StatelessWidget {
  TextEditingController nombre = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/imagenes/fondo1.png", fit: BoxFit.cover),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 130),
                  Text("Datos Usuario",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    fontSize: 18, // size in logical pixels
                  ),
                  textAlign: TextAlign.center,),
                  const SizedBox(height: 10),
                  _plantillaField(nombre, "Nombre"),
                  const SizedBox(height: 10),
                  _plantillaField(nombre, "Nombre"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plantillaField(TextEditingController controlador, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controlador,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
