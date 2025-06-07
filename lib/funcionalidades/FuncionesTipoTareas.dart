import 'package:cloud_firestore/cloud_firestore.dart';

import 'MainFunciones.dart';

Future<void> crearTipoTarea(String nombre, int puntuacion) async {
  final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
  if (unidadFamiliarRef == null) return;
  await unidadFamiliarRef.collection("TipoTareas").add({
    "nombre": nombre,
    "puntuacion": puntuacion,
  });
}

Future<void> editarTipoTarea(DocumentReference ref, String nombre, int puntuacion) async {
  await ref.update({
    "nombre": nombre,
    "puntuacion": puntuacion,
  });
}

Future<void> borrarTipoTarea(DocumentReference ref) async {
  await ref.delete();
}

Stream<QuerySnapshot> obtenerTiposTareasStream() async* {
  final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
  if (unidadFamiliarRef == null) {
    yield* const Stream.empty();
  } else {
    yield* unidadFamiliarRef.collection("TipoTareas").snapshots();
  }
}
