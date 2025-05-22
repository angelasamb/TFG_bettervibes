import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'EscogerPantalla.dart';

Future<void> salirUnidadFamiliar(BuildContext context, DocumentReference unidadFamiliarRef) async {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  if (user != null && unidadFamiliarRef != null) {
    final usuarioDocRef = firestore.collection('Usuario').doc(user.uid);
    final unidadDocRef = unidadFamiliarRef;

    try {
      await firestore.runTransaction((transaction) async {
        // 1. Lee primero todos los documentos que necesites
        final unidadSnapshot = await transaction.get(unidadDocRef);
        final datosUnidad = unidadSnapshot.data() as Map<String, dynamic>?;

        if (datosUnidad == null) {
          throw Exception("Unidad familiar no encontrada");
        }

        List<dynamic> participantes = datosUnidad['participantes'] ?? [];
        participantes = List.from(participantes); // copia mutable

        // Remover usuario actual de participantes
        participantes.removeWhere((ref) => ref.id == user.uid);

        // 2. Ahora haz las escrituras después de las lecturas
        // Quitar la unidad familiar del usuario
        transaction.update(usuarioDocRef, {'unidadFamiliarRef': FieldValue.delete()});

        if (participantes.isEmpty) {
          transaction.delete(unidadDocRef);
        } else {
          transaction.update(unidadDocRef, {'participantes': participantes});
        }
      });


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Has salido de la unidad familiar")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => EscogerPantalla()),
            (route) => false,
      );

    } catch (e, stackTrace) {
      print("Error al salir de unidad familiar: $e");
      print(stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al salir de la unidad familiar: $e")),
      );
    }
  } else {
    print("Usuario no autenticado o referencia unidad familiar nula.");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No hay usuario autenticado o unidad familiar seleccionada")),
    );
  }
}


Future<bool> cambiarContraseniaUnidadFamiliar({
  required BuildContext context,
  required String nuevaContrasenia,
  required String repetirContrasenia,
  required DocumentReference? unidadFamiliarRef,
  required VoidCallback onExito,
}) async {
  if (nuevaContrasenia.isEmpty || repetirContrasenia.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Por favor, rellena ambos campos")),
    );
    return false;
  }
  if (nuevaContrasenia != repetirContrasenia) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Las contraseñas no coinciden")),
    );
    return false;
  }
  if (unidadFamiliarRef == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: No hay unidad familiar asociada")),
    );
    return false;
  }
  try {
    await unidadFamiliarRef.update({'contrasenia': nuevaContrasenia});
    onExito();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contraseña de unidad familiar actualizada")),
    );
    return true;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al actualizar contraseña")),
    );
    return false;
  }
}