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

    await unidadFamiliarRef?.collection('eventos').add(nuevoEvento.toFirestore());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento creado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al crear evento: $e")),
    );
  }
}
// PARA BORRAR SOLO PASAR EL ID
Future<void> borrarEventoEnUnidadFamiliar({
  required BuildContext context,
  required String eventoId,
}) async {
  try {
    final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();

    await unidadFamiliarRef?.collection('eventos').doc(eventoId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento eliminado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al eliminar evento: $e")),
    );
  }
}
Future<void> editarEventoEnUnidadFamiliar({
  required BuildContext context,
  required String eventoId,
  required String nombre,
  String? descripcion,
  required Timestamp timestamp,
  DocumentReference? usuarioRefEvento,
}) async {
  try {
    final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();

    final eventoActualizado = Eventos(
      nombre: nombre,
      descripcion: descripcion,
      timestamp: timestamp,
      usuarioRef: usuarioRefEvento,
    );

    await unidadFamiliarRef?.collection('eventos').doc(eventoId).update(eventoActualizado.toFirestore());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento actualizado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al actualizar evento: $e")),
    );
  }
}
