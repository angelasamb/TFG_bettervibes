import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentReference?> obtenerUnidadFamiliarRefActual() async {
  try {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user == null) return null;

    final usuarioRef = firestore.collection('Usuario').doc(user.uid);
    final usuarioSnapshot = await usuarioRef.get();
    final usuarioData = usuarioSnapshot.data();

    return usuarioData?['unidadFamiliarRef'] as DocumentReference?;
  }catch(e){
    print("Error obteniendo unidad familiar: $e");
    return null;
  }
}
