import 'package:cloud_firestore/cloud_firestore.dart';

import 'MainFunciones.dart';

Future<void> CalculoPuntuacionSemanal(DocumentReference usuarioRef) async {

  final hoy = DateTime.now();
  final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
  if (unidadFamiliarRef == null);
  final inicioSemana = hoy.subtract(
    Duration(days: hoy.weekday - 1),
  ); //calcular para que sea lunes
  final finalSemana = inicioSemana.add(
    Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
  );
  final tareasSemana =
      await unidadFamiliarRef
          !.collection("Tareas")
          .where("usuarioRef", isEqualTo: usuarioRef)
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
  int puntuacionTotal = 0;
  for (var tarea in tareasSemana.docs) {
    final tipoTareaDoc =
        await (tarea["tipotareaRef"] as DocumentReference).get();
    print(tipoTareaDoc);
    final int puntos = tipoTareaDoc["puntuacion"] ?? 0;
    puntuacionTotal += puntos;
  }
  //actualizar la puntuacion semanal
  final usuarioDocRef = FirebaseFirestore.instance
      .collection("Usuario").doc(usuarioRef.id);
  await usuarioDocRef.update(
      {"puntuacion": puntuacionTotal});
}
