import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/widgets/personalizacion.dart';

import '../../../clases/ColorElegido.dart';
import '../../../funcionalidades/FuncionesTipoTareas.dart';
import '../../../widgets/ContadorNumerico.dart';
import '../../../widgets/PlantillaSelector.dart';

class PantallaModificarPerfil extends StatefulWidget {
  TextEditingController nombreController = TextEditingController();
  String imagenSeleccionada = "";
  ColorElegido colorSeleccionado = ColorElegido.Rojo;

  PantallaModificarPerfil(
    this.nombreController,
    this.imagenSeleccionada,
    this.colorSeleccionado,
  );

  @override
  State<PantallaModificarPerfil> createState() =>
      _PantallaCrearTipoTareaState();
}

class _PantallaCrearTipoTareaState extends State<PantallaModificarPerfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modificar perfil"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.gamaColores.shade500,centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(padding: EdgeInsets.all(20),child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Modificar perfil",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    plantillaField(widget.nombreController,"Nombre"),
                    const SizedBox(height: 10),
                    Text("Selecciona una imagen"),
                    PlantillaSelector(
                      esIcono: true,
                      itemSeleccionado: widget.imagenSeleccionada,
                      onSelect: (dynamic value) {
                        setState(() {
                          widget.imagenSeleccionada = value as String;
                        });
                      },
                    ),
                    PlantillaSelector(
                      esIcono: false,
                      itemSeleccionado: widget.colorSeleccionado,
                      onSelect: (dynamic value) {
                        setState(() {
                          widget.colorSeleccionado = value as ColorElegido;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _guardarCambios();
                        Navigator.pop(context, false);
                      },
                      child: Text("Guardar cambios"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          )
        ),
      ),
    );
  }

  Future<void> _guardarCambios() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user != null) {
      await firestore.collection("Usuario").doc(user.uid).update({
        "nombre": widget.nombreController.text.trim(),
        "fotoPerfil": widget.imagenSeleccionada,
        "colorElegido": widget.colorSeleccionado.name,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cambios guardados correctamente")),
      );
    }
  }
}
