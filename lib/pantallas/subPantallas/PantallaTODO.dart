import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearTipoTarea.dart';

import '../../widgets/ListaTareas.dart';

class PantallaTODO extends StatefulWidget {
  const PantallaTODO({super.key});

  @override
  State<PantallaTODO> createState() => _PantallaTODOState();
}

class _PantallaTODOState extends State<PantallaTODO> {
  DocumentReference? unidadFamiliarRef;
  String? user = FirebaseAuth.instance.currentUser?.uid;

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.gamaColores.shade500,
        foregroundColor: Colors.white,
        onPressed: () async {
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
                            builder: (_) => PantallaCrearEvento(tipoActividad: "tarea"),
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
                          MaterialPageRoute(
                            builder: (_) => PantallaCrearTipoTarea(),
                          ),
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
        },
        child: const Icon(Icons.add),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('TODO'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder(
                  stream: tareasRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final tareas = snapshot.data!.docs;

                    if (tareas.isEmpty) {
                      return const Center(child: Text("No hay tareas"));
                    }
                    return FutureBuilder<List<Widget>>(
                      future: listaTareasPorDia(context, user!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error al cargar tareas ${snapshot.error}",
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No hay tareas disponibles"));
                        }
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: ListView(children: snapshot.data!),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
