import 'package:cloud_firestore/cloud_firestore.dart';

import '../clases/Pagos.dart';

class FuncionesPagos {
  static Future<Pagos?> cargarPago({
    required DocumentReference unidadFamiliarRef,
    required String idPago,
  }) async {
    final doc = await unidadFamiliarRef.collection("Pagos").doc(idPago).get();
    if (!doc.exists) return null;
    return Pagos.fromFirestore(doc.data()!);
  }


  static Future<void> actualizarBalanceUsuario(DocumentReference usuarioRef, num cambio) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(usuarioRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final balanceActual = (data['balance'] ?? 0) as num;
      transaction.update(usuarioRef, {'balance': balanceActual + cambio});
    });
  }

  static Future<void> guardarPago({
    required DocumentReference unidadFamiliarRef,
    String? idPago,
    String? descripcion,
    required DocumentReference pagadorRef,
    required List<DocumentReference> participantes,
    required num precio,
    required DateTime fecha,
  }) async {
    final pagoNuevo = Pagos(
      descripcion: descripcion,
      pagadorRef: pagadorRef,
      participantes: participantes,
      precio: precio,
      timestamp: Timestamp.fromDate(fecha),
    );

    if (idPago == null) {
      await unidadFamiliarRef.collection("Pagos").add(pagoNuevo.toFirestore());

      await actualizarBalanceUsuario(pagadorRef, precio);
      final reparto = precio / participantes.length;
      for (final participante in participantes) {
        await actualizarBalanceUsuario(participante, -reparto);
      }
    } else {
      final pagoOriginal = await cargarPago(unidadFamiliarRef: unidadFamiliarRef, idPago: idPago);
      if (pagoOriginal != null) {
        await actualizarBalanceUsuario(pagoOriginal.pagadorRef, -pagoOriginal.precio);
        final repartoOriginal = pagoOriginal.precio / pagoOriginal.participantes.length;
        for (final participante in pagoOriginal.participantes) {
          await actualizarBalanceUsuario(participante, repartoOriginal);
        }
      }

      await unidadFamiliarRef.collection('Pagos').doc(idPago).update(pagoNuevo.toFirestore());

      await actualizarBalanceUsuario(pagadorRef, precio);
      final repartoNuevo = precio / participantes.length;
      for (final participante in participantes) {
        await actualizarBalanceUsuario(participante, -repartoNuevo);
      }
    }
  }

  static Future<void> eliminarPago({
    required DocumentReference unidadFamiliarRef,
    required String idPago,
  }) async {
    final pago = await cargarPago(unidadFamiliarRef: unidadFamiliarRef, idPago: idPago);
    if (pago == null) return;

    await actualizarBalanceUsuario(pago.pagadorRef, -pago.precio);
    final reparto = pago.precio / pago.participantes.length;
    for (final participante in pago.participantes) {
      await actualizarBalanceUsuario(participante, reparto);
    }

    await unidadFamiliarRef.collection('Pagos').doc(idPago).delete();
  }

  static Future<List<DocumentSnapshot>> obtenerUsuariosParticipantes(DocumentReference unidadFamiliarRef) async {
    final unidadSnap = await unidadFamiliarRef.get();
    final unidad = unidadSnap.data() as Map<String, dynamic>;
    List<DocumentReference> participantes = (unidad['participantes'] as List<
        dynamic>).cast<DocumentReference>();

    final usuariosSnapshots = await Future.wait(
        participantes.map((ref) => ref.get()));
    return usuariosSnapshots;
  }
  static Stream<QuerySnapshot> obtenerStreamPagosUnidadFamiliar(DocumentReference unidadFamiliarRef) {
    return unidadFamiliarRef
        .collection('Pagos')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

