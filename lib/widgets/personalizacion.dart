import 'package:flutter/material.dart';

import '../clases/ColorElegido.dart';


  Widget plantillaField(
      TextEditingController controlador,
      String hint, {
        bool esContrasena = false,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controlador,
        obscureText: esContrasena,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

