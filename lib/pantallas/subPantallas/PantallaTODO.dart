import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesUsuario.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';

import '../../clases/Usuario.dart';

class PantallaTODO extends StatefulWidget {
  const PantallaTODO({super.key});

  @override
  State<PantallaTODO> createState() => _PantallaTODOState();
}

class _PantallaTODOState extends State<PantallaTODO> {
  String? unidadFamiliarId;
  String? user = FirebaseAuth.instance.currentUser?.uid;
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
        backgroundColor: Colors.gamaColores.shade500,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaCrearEvento(tipoActividad: "tarea"),
            ),
          );
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
    Map<DateTime, List<DocumentSnapshot>> tareasPorDia = {};

    for (var tarea in tareas) {
      DateTime fechaClave = (tarea["timestamp"] as Timestamp).toDate();
      DateTime soloFecha = DateTime(
        fechaClave.year,
        fechaClave.month,
        fechaClave.day,
      );
      tareasPorDia.putIfAbsent(soloFecha, () => []).add(tarea);
    }
    final tareasOrdenadas =
        tareasPorDia.keys.toList()..sort((a, b) => a.compareTo(b));

    List<Widget> lista = [];

    for (var fecha in tareasOrdenadas) {
      final tareaDia = tareasPorDia[fecha]!;
      tareaDia.sort(
        (a, b) => (a["timestamp"] as Timestamp).compareTo(
          b["timestamp"] as Timestamp,
        ),
      );
      final String fechaFormateada = DateFormat(
        "EEE, dd MMM yyyy",
      ).format(fecha);
    var tipoTareaRef;
      lista.add(
        Padding(padding: const EdgeInsets.all(8), child: Text(fechaFormateada)),
      );
      for (var tarea in tareasPorDia[fecha]!) {
        tipoTareaRef = tarea["tipotareaRef"] as DocumentReference;
        final usuarioRef = tarea["usuarioRef"] as DocumentReference;
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
        String descripcionTareas = tarea["descripcion"] ?? "";
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
              if(user==usuarioRef.id){
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaCrearEvento(tareaEditar: tarea.reference),
              ),
            );}
            },
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nombreTipoTarea,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorUsuario,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          hora,
                          style: TextStyle(fontSize: 18, color: colorUsuario),
                        ),

                        if (tarea["realizada"] == false)
                          IconButton(
                            onPressed: () async {
                              final confirmar = await showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text("Confirmar"),
                                      content: Text(
                                        "¿Quieres marcar esta tarea como completada?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: Text("Sí"),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirmar == true) {
                                await FirebaseFirestore.instance
                                    .collection("UnidadFamiliar")
                                    .doc(unidadFamiliarId)
                                    .collection("Tareas")
                                    .doc(tarea.id)
                                    .update({"realizada": true});
                              }
                            },
                            icon: Icon(Icons.check),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (descripcionTareas.isNotEmpty) ...[
                  //si no hay descripcion no está el campo
                  Text(
                    descripcionTareas,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 10),
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
