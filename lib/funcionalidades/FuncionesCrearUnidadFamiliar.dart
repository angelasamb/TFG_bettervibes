import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/UnidadFamiliar.dart';

import '../clases/ColorElegido.dart';
import '../datosDePrueba/TipoDeEventosDePrueba.dart';

final nombreColeccionUnidadFamiliar = "UnidadFamiliar";
final nombreColeccionUsuarios = "Usuario";

Future<bool> crearUnidadFamiliar(String nombre, String contrasena) async {
  try {
    final autentificacion = FirebaseAuth.instance;
    final baseDatos = FirebaseFirestore.instance;
    final usuarioConectado = autentificacion.currentUser;

    if (usuarioConectado == null) return false;

    final idUsuario = usuarioConectado.uid;
    DocumentReference usuarioRef = baseDatos.collection(nombreColeccionUsuarios).doc(idUsuario);

    List<DocumentReference> participantes = [usuarioRef];

    UnidadFamiliar nuevaUnidadFamiliar = UnidadFamiliar(
      contrasenia: contrasena,
      nombre: nombre,
      participantes: participantes,
    );

    final datosAFirebase = nuevaUnidadFamiliar.toFirestore();

    DocumentReference unidadRef = await baseDatos
        .collection(nombreColeccionUnidadFamiliar)
        .add(datosAFirebase);

    await usuarioRef.update({
      "unidadFamiliarRef": unidadRef,
      "admin": true,
    });
    await asignarColorAleatorio(usuarioRef);
    insertarTareasEjemploEnUnidadFamiliar();
    return true;
  } catch (e) {
    print("ERROR: $e");
    return false;
  }
}

Future<bool> unirseUnidadFamiliar(String unidadFamiliarId, String contrasenaIntento) async {
  try {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final usuarioConectado = auth.currentUser;

    if (usuarioConectado == null) return false;

    final idUsuario = usuarioConectado.uid;
    DocumentReference usuarioRef = db.collection(nombreColeccionUsuarios).doc(idUsuario);
    DocumentReference unidadRef = db.collection(nombreColeccionUnidadFamiliar).doc(unidadFamiliarId);

    DocumentSnapshot fotoUnidadFamiliar = await unidadRef.get();
    if (!fotoUnidadFamiliar.exists) return false;

    UnidadFamiliar unidad = UnidadFamiliar.fromFirestore(fotoUnidadFamiliar.data() as Map<String, dynamic>);
    if (unidad.contrasenia != contrasenaIntento) return false;

    await usuarioRef.update({
      "unidadFamiliarRef": unidadRef,
      "admin": false,
    });

    try {
      await unidadRef.update({
        "participantes": FieldValue.arrayUnion([usuarioRef]),
      });
     await asignarColorAleatorio(usuarioRef);
    } catch (e) {
      print("ERROR: $e");
    }

    return true;
  } catch (e) {
    print("ERROR: $e");
    return false;
  }
}


Future<void> asignarColorAleatorio(DocumentReference<Object?> usuarioRef) async {
  final coloresOcupados = await listaColoresOcupados();
  final disponibles = ColorElegido.values.where((color)=>!coloresOcupados.contains(color)).toList();
  if(disponibles.isNotEmpty){
    disponibles.shuffle();
    await usuarioRef.update({"colorElegido":disponibles.first.name});
  }
}
