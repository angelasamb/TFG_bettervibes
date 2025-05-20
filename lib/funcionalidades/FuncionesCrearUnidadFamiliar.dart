import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/UnidadFamiliar.dart';

final nombreColeccionUnidadFamiliar = 'UnidadFamiliar';
final nombreColeccionUsuarios = 'Usuario';

Future<bool> crearUnidadFamiliar(String nombre, String contrasena) async {
  try {
    final autentificacion = FirebaseAuth.instance;
    final baseDatos = FirebaseFirestore.instance;
    final usuarioConectado = autentificacion.currentUser;

    if (usuarioConectado == null) {
      print("ERROR: No hay usuario registrado, no se ha podido crear usuario");
      return false;
    }
    final idUsuario = usuarioConectado.uid;
    DocumentReference usuarioRef = baseDatos.collection(nombreColeccionUsuarios).doc(idUsuario);
    List<DocumentReference> participantes = [usuarioRef];


    UnidadFamiliar nuevaUnidadFamiliar = UnidadFamiliar(contrasenia: contrasena, nombre: nombre, participantes: participantes);
    DocumentReference unidadRef = await baseDatos.collection(nombreColeccionUnidadFamiliar).add(nuevaUnidadFamiliar.toFirestore());

    await usuarioRef.update({
      'unidadFamiliarRef': unidadRef,
      'admin': true,
    });

    return(true);
  } catch (e) {
    print("ERROR: Error en crearUnidadFamiliar: $e");
    return(false);
  }
}
Future<bool> unirseUnidadFamiliar(String unidadFamiliarId, String contrasenaIntento) async {
  try {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final usuarioConectado = auth.currentUser;

    if (usuarioConectado == null) {
      print("ERROR: No hay usuario registrado");
      return false;
    }

    DocumentReference unidadRef = db.collection(nombreColeccionUnidadFamiliar).doc(unidadFamiliarId);
    DocumentSnapshot fotoUnidadFamiliar = await unidadRef.get();

    if (!fotoUnidadFamiliar.exists) {
      print("ERROR: La unidad familiar no existe");
      return false;
    }

    UnidadFamiliar unidad = UnidadFamiliar.fromFirestore(fotoUnidadFamiliar.data() as Map<String, dynamic>);

    if (unidad.contrasenia != contrasenaIntento) {
      print("ERROR: Contraseña incorrecta");
      return false;
    }

    final idUsuario = usuarioConectado.uid;
    DocumentReference usuarioRef = db.collection(nombreColeccionUsuarios).doc(idUsuario);

    // Añadimos usuario a unidad familiar
    if (!unidad.participantes.contains(usuarioRef)) {
      unidad.participantes.add(usuarioRef);
    }

    // Actualizamos usuario
    await usuarioRef.update({
      'unidadFamiliarRef': unidadRef,
      'admin': false,
    });

    // Actualizamos unidad familiar
    await unidadRef.update({
      'participantes': unidad.participantes,
    });

    return true;

  } catch (e) {
    print("ERROR: Error al unirse a unidad familiar: $e");
    return false;
  }
}