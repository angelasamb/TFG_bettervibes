import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../clases/Eventos.dart';
import 'MainFunciones.dart';

Future<void> crearEventoEnUnidadFamiliar({
  required BuildContext context,
  required String nombre,
  String? descripcion,
  required Timestamp timestamp,
  DocumentReference? usuarioRefEvento,
}) async {
  try {
    final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();

    final nuevoEvento = Eventos(
      nombre: nombre,
      descripcion: descripcion,
      timestamp: timestamp,
      usuarioRef: usuarioRefEvento,
    );

    await unidadFamiliarRef
        !.collection("Eventos")
        .add(nuevoEvento.toFirestore());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento creado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error al crear evento: $e")));
  }
}

// PARA BORRAR SOLO PASAR EL ID
Future<void> borrarDocEnUnidadFamiliar({
  required BuildContext context,
  required DocumentReference doc,
}) async {
  try {
    await doc.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento eliminado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error al eliminar evento: $e")));
  }
}

Future<void> editarEventoEnUnidadFamiliar({
  required BuildContext context,
  required eventoEditar,
  required String nombre,
  String? descripcion,
  required Timestamp timestamp,
  DocumentReference? usuarioRefEvento,
}) async {
  try {
    await eventoEditar.update({
      "nombre": nombre,
      "timestamp": timestamp,
      "usuarioRef": usuarioRefEvento,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento actualizado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error al actualizar evento: $e")));
  }
}
