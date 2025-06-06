import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/clases/Tareas.dart';
import '../clases/Eventos.dart';

Future<void> crearTareaEnUnidadFamiliar({
  required BuildContext context,
  required bool realizada,
  required Timestamp timestamp,
  required DocumentReference tipoTareaRef,
  required String descripcion,
}) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final user = auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("No hay usuario autenticado")));
    return;
  }

  try {
    final usuarioRef = firestore.collection("Usuario").doc(user.uid);
    final usuarioSnapshot = await usuarioRef.get();
    final usuarioData = usuarioSnapshot.data();

    if (usuarioData == null || !usuarioData.containsKey("unidadFamiliarRef")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ERROR: Unidad familiar no encontrada")),
      );
      return;
    }

    final unidadFamiliarRef =
        usuarioData["unidadFamiliarRef"] as DocumentReference;

    final nuevaTarea = Tareas(
      descripcion: descripcion,
      realizada: realizada,
      timestamp: timestamp,
      tipoTareaRef: tipoTareaRef,
      usuarioRef: usuarioRef,
    );

    await unidadFamiliarRef.collection("Tareas").add(nuevaTarea.toFirestore());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Tarea creada correctamente")));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error al crear tarea: $e")));
  }
}

Future<void> actualizarTareaEnUnidadFamiliar({
  required BuildContext context,
  required bool realizada,
  required Timestamp timestamp,
  required DocumentReference tipoTareaRef,
  required String descripcion,
  required DocumentReference tarea,
}) async {

}


