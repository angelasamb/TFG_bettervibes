import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EscogerPantalla.dart';

Future<void> salirUnidadFamiliar(BuildContext context, DocumentReference unidadFamiliarRef) async {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  if (user != null && unidadFamiliarRef != null) {
    final usuarioDocRef = firestore.collection('Usuario').doc(user.uid);
    final unidadDocRef = unidadFamiliarRef;

    try {
      await firestore.runTransaction((transaction) async {
        final unidadSnapshot = await transaction.get(unidadDocRef);
        final datosUnidad = unidadSnapshot.data() as Map<String, dynamic>?;

        if (datosUnidad == null) throw Exception("Unidad familiar no encontrada");

        List<dynamic> participantes = datosUnidad['participantes'] ?? [];
        participantes = List.from(participantes);

        participantes.removeWhere((ref) => ref.id == user.uid);

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al salir de la unidad familiar: $e")),
      );
    }
  } else {
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

Future<void> actualizarAdmin(String uid, bool esAdmin) async {
  final db = FirebaseFirestore.instance;
  final userRef = db.collection('Usuario').doc(uid);
  await userRef.update({'admin': esAdmin});
}

Future<void> expulsarUsuario(BuildContext context, DocumentReference usuarioRef, DocumentReference? unidadFamiliarRef) async {
  final firestore = FirebaseFirestore.instance;

  if (unidadFamiliarRef == null) return;

  try {
    await firestore.runTransaction((transaction) async {
      final unidadSnapshot = await transaction.get(unidadFamiliarRef);
      final datosUnidad = unidadSnapshot.data() as Map<String, dynamic>?;

      if (datosUnidad == null) throw Exception("Unidad familiar no encontrada");

      List<dynamic> participantes = datosUnidad['participantes'] ?? [];
      participantes = List.from(participantes);

      participantes.removeWhere((ref) => ref.id == usuarioRef.id);

      if (participantes.isEmpty) {
        transaction.delete(unidadFamiliarRef);
      } else {
        transaction.update(unidadFamiliarRef, {'participantes': participantes});
      }

      transaction.update(usuarioRef, {'unidadFamiliarRef': FieldValue.delete()});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Usuario expulsado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al expulsar usuario: $e")),
    );
  }
}
