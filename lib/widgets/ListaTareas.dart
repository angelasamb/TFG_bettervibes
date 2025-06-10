import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_bettervibes/funcionalidades/PuntuacionSemanal.dart';

import '../clases/ColorElegido.dart';
import '../funcionalidades/MainFunciones.dart';
import '../pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';

Future<List<Widget>> listaTareasPorDia(
  BuildContext context,
  String user,
  int tipo,
) async {
  final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
  if (unidadFamiliarRef == null) return [];
  final hoy = DateTime.now();
  final hoySoloFecha = DateTime(hoy.year, hoy.month, hoy.day);
  final inicioSemana = hoy.subtract(
    Duration(days: hoy.weekday - 1),
  ); //calcular para que sea lunes
  final finalSemana = inicioSemana.add(
    Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
  );
  final QuerySnapshot queryTareas;
  if (tipo == 1) {
    queryTareas = await unidadFamiliarRef.collection("Tareas").get();
  } else if (tipo == 2) {
    queryTareas =
        await unidadFamiliarRef
            .collection("Tareas")
            .where(
              "timestamp",
              isGreaterThanOrEqualTo: Timestamp.fromDate(hoySoloFecha),
            )
            .get();
  } else {
    queryTareas =
        await unidadFamiliarRef
            .collection("Tareas")
            .where("realizada", isEqualTo: true)
            .where(
              "timestamp",
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicioSemana),
            )
            .where(
              "timestamp",
              isLessThanOrEqualTo: Timestamp.fromDate(finalSemana),
            )
            .get();
  }
  final tareas = queryTareas.docs;
  //sets para las referencias
  final tipoTareaIds =
      tareas.map((t) => (t["tipotareaRef"] as DocumentReference).id).toSet();
  final usuarioIds =
      tareas.map((t) => (t["usuarioRef"] as DocumentReference).id).toSet();

  //carga tipos de tarea
  final tipoTareasSnapshot = await Future.wait(
    tipoTareaIds.map(
      (id) => unidadFamiliarRef.collection("TipoTareas").doc(id).get(),
    ),
  );
  final tipoTareasMap = {for (var doc in tipoTareasSnapshot) doc.id: doc};

  //carga usuarios
  final usuarioSnapshot = await Future.wait(
    usuarioIds.map(
      (id) => FirebaseFirestore.instance.collection("Usuario").doc(id).get(),
    ),
  );
  final usuariosMap = {for (var doc in usuarioSnapshot) doc.id: doc};

  Map<DateTime, List<DocumentSnapshot>> tareasPorDia = {};

  for (var tarea in tareas) {
    //iterador sobre cada tarea
    //fecha de la tarea
    final fechaCompleta = (tarea["timestamp"] as Timestamp).toDate();
    DateTime soloFecha = DateTime(
      //elimina la hora
      fechaCompleta.year,
      fechaCompleta.month,
      fechaCompleta.day,
    );
    tareasPorDia
        .putIfAbsent(soloFecha, () => [])
        .add(tarea); //tarea agrupada por fecha
  }
  final fechasOrdenadas =
      tareasPorDia.keys.toList()
        ..sort((a, b) => a.compareTo(b)); //ordenar tareas cronologicamente

  List<Widget> lista = [];

  for (var fecha in fechasOrdenadas) {
    //iterador sobre cada dia con tareas
    final tareaDia = tareasPorDia[fecha]!;
    tareaDia.sort(
      //ordena tareas por hora
      (a, b) =>
          (a["timestamp"] as Timestamp).compareTo(b["timestamp"] as Timestamp),
    );
    final String fechaFormateada = DateFormat(
      //formateo de fecha
      "EEE, dd MMM yyyy",
    ).format(fecha);
    lista.add(
      Padding(padding: const EdgeInsets.all(8), child: Text(fechaFormateada)),
    );
    for (var tarea in tareaDia) {
      //iterador de tareas sobre ese dia para mostrarlas por pantalla
      final tipoTareaRef = tarea["tipotareaRef"] as DocumentReference;
      final usuarioRef = tarea["usuarioRef"] as DocumentReference;
      final usuario = usuariosMap[usuarioRef.id];
      final tipoTarea = tipoTareasMap[tipoTareaRef.id];

      final String nombreTipoTarea = tipoTarea?["nombre"] ?? "Sin tipo";
      final String descripcionTareas = tarea["descripcion"] ?? "";
      final Color colorUsuario = getColorFromEnum(usuario?["colorElegido"]);
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
                  builder:
                      (context) =>
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

                      if (tarea["realizada"] == false && user == usuarioRef.id)
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
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text("Sí"),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirmar == true) {
                              await unidadFamiliarRef
                                  .collection("Tareas")
                                  .doc(tarea.id)
                                  .update({"realizada": true});
                              CalculoPuntuacionSemanal(usuarioRef);
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
                    fontWeight: FontWeight.normal,
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
