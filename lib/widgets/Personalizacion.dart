import 'package:flutter/material.dart';

Widget plantillaField(
  TextEditingController controlador,
  String label, {
  bool esContrasena = false,
}) {
  bool ocultarContrasena = esContrasena;
  return StatefulBuilder(
    builder: (context, setState) {
      return TextField(
        controller: controlador,
        obscureText: ocultarContrasena,
        maxLength: label == "Nombre" ? 10 : 30,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          hintStyle: const TextStyle(color: Colors.grey),
          suffix:
              esContrasena
                  ? IconButton(
                    icon: Icon(
                      ocultarContrasena
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarContrasena = !ocultarContrasena;
                      });
                    },
                  )
                  : null,
        ),
      );
    },
  );
}
