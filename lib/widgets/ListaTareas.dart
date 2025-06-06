
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../clases/ColorElegido.dart';
import '../funcionalidades/MainFunciones.dart';
import '../pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';

Future<List<Widget>> listaTareasPorDia(
    List<QueryDocumentSnapshot> tareas,
    BuildContext context,
    String user
    ) async {
  Map<DateTime, List<DocumentSnapshot>> tareasPorDia = {};

  for (var tarea in tareas) {//iterador sobre cada tarea
    //fecha de la tarea
    DateTime fechaClave = (tarea["timestamp"] as Timestamp).toDate();
    DateTime soloFecha = DateTime(//elimina la hora
      fechaClave.year,
      fechaClave.month,
      fechaClave.day,
    );
    tareasPorDia.putIfAbsent(soloFecha, () => []).add(tarea); //tarea agrupada por fecha
  }
  final tareasOrdenadas =
  tareasPorDia.keys.toList()..sort((a, b) => a.compareTo(b));//ordenar tareas cronologicamente

  List<Widget> lista = [];

  for (var fecha in tareasOrdenadas) { //iterador sobre cada dia con tareas
    final tareaDia = tareasPorDia[fecha]!;
    tareaDia.sort(//ordena tareas por hora
          (a, b) => (a["timestamp"] as Timestamp).compareTo(
        b["timestamp"] as Timestamp,
      ),
    );
    final String fechaFormateada = DateFormat( //formateo de fecha
      "EEE, dd MMM yyyy",
    ).format(fecha);
    lista.add(
      Padding(padding: const EdgeInsets.all(8), child: Text(fechaFormateada)),
    );
    for (var tarea in tareasPorDia[fecha]!) { //iterador de tareas sobre ese dia para mostrarlas por pantalla
      final tipoTareaRef = tarea["tipotareaRef"] as DocumentReference;
      final usuarioRef = tarea["usuarioRef"] as DocumentReference;
      final usuario =
      await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(usuarioRef.id)
          .get();
      final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
      final tipoTarea =
      await unidadFamiliarRef!.collection("TipoTareas")
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
              if (user == usuarioRef.id) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PantallaCrearEvento(tareaEditar: tarea.reference),
                  ),
                );
              }
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
                                    (context) =>
                                    AlertDialog(
                                      title: Text("Confirmar"),
                                      content: Text(
                                        "¿Quieres marcar esta tarea como completada?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                              Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                              Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: Text("Sí"),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirmar == true) {

                                await unidadFamiliarRef.collection("Tareas")
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
                  //si no hay descripcion no muestra el campo
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