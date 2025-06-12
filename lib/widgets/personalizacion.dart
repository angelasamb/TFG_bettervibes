import 'package:flutter/material.dart';

import '../clases/ColorElegido.dart';


  Widget plantillaField(
      TextEditingController controlador,
      String label, {
        bool esContrasena = false,
      }) {
    return TextField(
        controller: controlador,
        obscureText: esContrasena,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      maxLength: label=="Nombre"? 10:30,
      );

  }

