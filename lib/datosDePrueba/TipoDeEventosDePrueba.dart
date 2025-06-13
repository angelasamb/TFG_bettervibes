import 'package:tfg_bettervibes/clases/TipoTareas.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:firebase_auth/firebase_auth.dart';

List<TipoTareas> tareasEjemplo() {
  return [
    TipoTareas(
      nombre: "Lavar los platos",
      puntuacion: 5,
    ),
    TipoTareas(
      nombre: "Aspirar la casa",
      puntuacion: 10,
    ),
    TipoTareas(
      nombre: "Sacar la basura",
      puntuacion: 3,
    ),
    TipoTareas(
      nombre: "Limpiar el baño",
      puntuacion: 8,
    ),
  ];
}

Future<void> insertarTareasEjemploEnUnidadFamiliar() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
    if (unidadFamiliarRef == null) throw Exception("No se encontró unidad familiar");

    final tipoTareasRef = unidadFamiliarRef.collection("TipoTareas");
    final tareas = tareasEjemplo();

    for (var tarea in tareas) {
      await tipoTareasRef.add(tarea.toFirestore());
    }

    print("Tareas de ejemplo insertadas correctamente");
  } catch (e) {
    print("Error insertando tareas de ejemplo: $e");
  }
}
