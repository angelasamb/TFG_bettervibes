import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/Pagos.dart';
import '../clases/Usuario.dart';

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
    List<DocumentReference> participantes = (unidad['participantes'] as List<dynamic>).cast<DocumentReference>();
    final usuariosSnapshots = await Future.wait(participantes.map((ref) => ref.get()));
    return usuariosSnapshots;
  }

  static Stream<QuerySnapshot> obtenerStreamPagosUnidadFamiliar(DocumentReference unidadFamiliarRef) {
    return unidadFamiliarRef
        .collection('Pagos')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
Future<void> generarBizums(List<Map<String, dynamic>> usuariosData, List<String> usuariosId, DocumentReference unidadRef) async {
  final firestore = FirebaseFirestore.instance;
  final bizumRef = unidadRef.collection('bizums');

  final anterior = await bizumRef.get();
  for (var doc in anterior.docs) {
    await doc.reference.delete();
  }

  List<Map<String, dynamic>> usuarios = List.generate(usuariosData.length, (index) {
    final data = usuariosData[index];
    final id = usuariosId[index];
    return {
      'id': id,
      'balance': data['balance'] ?? 0.0,
    };
  });

  final deudores = usuarios.where((u) => u['balance'] < 0).toList()
    ..sort((a, b) => (a['balance'] as num).compareTo(b['balance'] as num));
  final acreedores = usuarios.where((u) => u['balance'] > 0).toList()
    ..sort((a, b) => (b['balance'] as num).compareTo(a['balance'] as num));

  while (deudores.isNotEmpty && acreedores.isNotEmpty) {
    final deudor = deudores.first;
    final acreedor = acreedores.first;

    final cantidad = (deudor['balance'].abs() as num).compareTo(acreedor['balance'] as num) < 0
        ? deudor['balance'].abs()
        : acreedor['balance'];

    final refDeudor = firestore.collection('Usuario').doc(deudor['id']);
    final refAcreedor = firestore.collection('Usuario').doc(acreedor['id']);

    await bizumRef.add({
      'precio': cantidad,
      'personaPaga': refDeudor,
      'personaRecibe': refAcreedor,
      'hecho': false,
    });

    deudor['balance'] += cantidad;
    acreedor['balance'] -= cantidad;

    if (deudor['balance'] >= 0) deudores.removeAt(0);
    if (acreedor['balance'] <= 0) acreedores.removeAt(0);
  }
}
Future<void> actualizarEstadoBizum(
    DocumentReference bizumRef,
    Map<String, dynamic> data,
    bool nuevoEstado,
    ) async {
  final firestore = FirebaseFirestore.instance;

  if (nuevoEstado == true && (data['hecho'] ?? false) == false) {
    final refDeudor = data['personaPaga'] as DocumentReference;
    final refAcreedor = data['personaRecibe'] as DocumentReference;
    final cantidad = data['precio'] as num;

    await firestore.runTransaction((transaction) async {
      final deudorSnap = await transaction.get(refDeudor);
      final acreedorSnap = await transaction.get(refAcreedor);

      if (!deudorSnap.exists || !acreedorSnap.exists) return;

      final deudorData = deudorSnap.data() as Map<String, dynamic>;
      final acreedorData = acreedorSnap.data() as Map<String, dynamic>;

      final nuevoBalanceDeudor = (deudorData['balance'] ?? 0) + cantidad;
      final nuevoBalanceAcreedor = (acreedorData['balance'] ?? 0) - cantidad;

      transaction.update(refDeudor, {'balance': nuevoBalanceDeudor});
      transaction.update(refAcreedor, {'balance': nuevoBalanceAcreedor});
      transaction.update(bizumRef, {'hecho': true});
    });
  } else {
    await bizumRef.update({'hecho': nuevoEstado});
  }
}
