import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearTipoTarea.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaTodasTareas.dart';

import '../../widgets/MostrarTareas.dart';

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({super.key});

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  DocumentReference? unidadFamiliarRef;
  String? user = FirebaseAuth.instance.currentUser?.uid;
  bool todas = false;

  @override
  void initState() {
    super.initState();
    _cargarUnidadFamiliar();
  }

  Future<void> _cargarUnidadFamiliar() async {
    final ref = await obtenerUnidadFamiliarRefActual();
    setState(() {
      unidadFamiliarRef = ref;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (unidadFamiliarRef == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tareasRef = unidadFamiliarRef!.collection("Tareas");
    return Scaffold(
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.gamaColores.shade500,
              foregroundColor: Colors.white,
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaTodasTareas(),
                  ),
                );
              },
              child: const Text("Todas"),
            ),
          ),
          Positioned(
            bottom: 90, // un poco más arriba que el anterior
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.gamaColores.shade500,
              foregroundColor: Colors.white,
              onPressed: () async {
                _accionesBotones();
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: MostrarTareas(
              unidadFamiliarRef: unidadFamiliarRef,
              user: user,
              tipo: 2,
              tareasRef: tareasRef,
            ),
          ),
        ],
      ),
    );
  }

  void _accionesBotones() async {
    final esAdmin = await esUsuarioActualAdmin();

    if (esAdmin) {
      // Para admins, mostramos un bottom sheet con dos opciones
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.task_alt),
                title: Text('Crear tarea'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => PantallaCrearEvento(tipoActividad: "tarea"),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.task),
                title: Text('Crear TipoTarea'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PantallaCrearTipoTarea()),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      // Para usuarios normales, solo crear tarea
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaCrearEvento(tipoActividad: "tarea"),
        ),
      );
    }
  }
}
