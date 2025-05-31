import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesUsuario.dart';

import '../../clases/Usuario.dart';

class PantallaTODO extends StatefulWidget {
  const PantallaTODO({super.key});

  @override
  State<PantallaTODO> createState() => _PantallaTODOState();
}

class _PantallaTODOState extends State<PantallaTODO> {
  String filtroDefecto = "Mis tareas";
  List<String> _filtros = ["Mis tareas", "Completadas", "Pendientes", "Todas"];
  String? unidadFamiliarId;

  @override
  void initState() {
    super.initState();
    cargarUnidadFamiliar();
  }

  void cargarUnidadFamiliar() async {
    final id = await obtenerUnidadFamiliarId();
    setState(() {
      unidadFamiliarId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (unidadFamiliarId == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final tareasRef = FirebaseFirestore.instance
        .collection("UnidadFamiliar")
        .doc(unidadFamiliarId)
        .collection("Tareas");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.gamaColores.shade200,
        child: Icon(Icons.add, color: Colors.white),
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
              child: StreamBuilder(
                stream: tareasRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  final tareas = snapshot.data!.docs;

                  if (tareas.isEmpty) {
                    return Center(child: Text("No hay tareas"));
                  }
                  return FutureBuilder<List<Widget>>(
                    future: _listaTareasPorDia(tareas),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error al cargar tareas ${snapshot.error}",
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No hay tareas disponibles"));
                      }
                      return ListView(children: snapshot.data!);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Widget>> _listaTareasPorDia(
      List<QueryDocumentSnapshot> tareas,
      ) async {
    Map<String, List<DocumentSnapshot>> tareasPorDia = {};
    String fechaClave = "";
    DateTime fecha;
    for (var tarea in tareas) {
      fecha = (tarea["timestamp"] as Timestamp).toDate();
      fechaClave = DateFormat('EEEE, dd MMM yyyy').format(fecha);
      tareasPorDia.putIfAbsent(fechaClave, () => []).add(tarea);
    }
    List<String> tareasOrdenadas =
    tareasPorDia.keys.toList()..sort((a, b) => b.compareTo(a));
    List<Widget> lista = [];
    for (var fecha in tareasOrdenadas) {
      lista.add(Padding(padding: const EdgeInsets.all(8), child: Text(fecha)));
      for (var tarea in tareasPorDia[fecha]!) {
        final tipoTareaRef = tarea["tipoTarea"] as DocumentReference;
        final usuarioRef = tarea["idUsuario"] as DocumentReference;
        final usuario =
        await FirebaseFirestore.instance
            .collection("Usuario")
            .doc(usuarioRef.id)
            .get();

        final tipoTarea =
        await FirebaseFirestore.instance
            .collection("UnidadFamiliar")
            .doc(unidadFamiliarId)
            .collection("TipoTareas")
            .doc(tipoTareaRef.id)
            .get();

        String nombreTipoTarea = tipoTarea.get("nombre");
        String descripcionTareas = tipoTarea.get("descripcion")??"";
        Color colorUsuario = getColorFromEnum(usuario.get("colorElegido"));
        final hora = DateFormat("HH:mm").format(tarea["timestamp"].toDate());

        lista.add(
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              print("Tarea presionada");
            },
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      nombreTipoTarea,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorUsuario,
                      ),
                    ),
                    Text(
                      hora,
                      style: TextStyle(fontSize: 18, color: colorUsuario),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if(descripcionTareas.isNotEmpty)...[ //si no hay descripcion no está el campo
                Text(
                  descripcionTareas,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorUsuario,
                  ),
                ),

                const SizedBox(height: 10)
                ],
              ],
            ),
          ),
        );
      }
    }
    return lista;
  }
}
