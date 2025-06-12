import 'package:flutter/material.dart';

Widget plantillaField(
  TextEditingController controlador,
  String label, {
  bool esContrasena = false,
}) {
  return TextField(
    controller: controlador,
    obscureText: esContrasena,
    maxLength: label == "Nombre" ? 10 : 30,
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      labelText: label,
      hintStyle: const TextStyle(color: Colors.grey),
    ),
  );
}
