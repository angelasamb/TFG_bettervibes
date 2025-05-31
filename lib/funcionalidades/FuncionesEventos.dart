import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../clases/Eventos.dart';

Future<void> crearEventoEnUnidadFamiliar({
  required BuildContext context,
  required String nombre,
  String? descripcion,
  required Timestamp timestamp,
  DocumentReference? usuarioRefEvento,
}) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final user = auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No hay usuario autenticado")),
    );
    return;
  }

  try {
    final usuarioRef = firestore.collection('Usuario').doc(user.uid);
    final usuarioSnapshot = await usuarioRef.get();
    final usuarioData = usuarioSnapshot.data();

    if (usuarioData == null || !usuarioData.containsKey('unidadFamiliarRef')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ERROR: Unidad familiar no encontrada")),
      );
      return;
    }

    final unidadFamiliarRef = usuarioData['unidadFamiliarRef'] as DocumentReference;

    final nuevoEvento = Eventos(
      nombre: nombre,
      descripcion: descripcion,
      timestamp: timestamp,
      usuarioRef: usuarioRefEvento,
    );

    await firestore.runTransaction((transaction) async {
      final unidadSnapshot = await transaction.get(unidadFamiliarRef);
      final unidadData = unidadSnapshot.data() as Map<String, dynamic>?;

      if (unidadData == null) throw Exception("ERROR: Unidad familiar no encontrada");

      List<dynamic> eventosUnidadFamiliar = unidadData['eventos'] ?? [];
      eventosUnidadFamiliar = List.from(eventosUnidadFamiliar);

      eventosUnidadFamiliar.add(nuevoEvento.toFirestore());

      transaction.update(unidadFamiliarRef, {'eventos': eventosUnidadFamiliar});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Evento creado correctamente")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al crear evento: $e")),
    );
  }
}
