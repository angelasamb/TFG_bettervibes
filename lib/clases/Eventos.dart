import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/ClaseBase.dart';

class Eventos extends ClaseBase {
  String? id;
  String? _descripcion;
  String _nombre;
  Timestamp _timestamp;
  DocumentReference? _usuarioRef;

  Eventos({
    String? descripcion,
    required String nombre,
    required Timestamp timestamp,
    DocumentReference? usuarioRef,
    this.id,
  }) : _descripcion = descripcion,
       _nombre = nombre,
       _timestamp = timestamp,
       _usuarioRef = usuarioRef;

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "timestamp": _timestamp,
      "usuarioRef": _usuarioRef,
      "nombre": _nombre,
      "descripcion": _descripcion,
    };
  }

  factory Eventos.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Eventos(
      descripcion: map["descripcion"] as String?,
      id: doc.id,
      nombre: map["nombre"] as String,
      timestamp: map["timestamp"] as Timestamp,
      usuarioRef: map["usuarioRef"] != null ? map["usuarioRef"] as DocumentReference : null,
    );
  }

  DocumentReference? get usuarioRef => _usuarioRef;

  set usuarioRef(DocumentReference? value) {
    _usuarioRef = value;
  }

  Timestamp get timestamp => _timestamp;

  set timestamp(Timestamp value) {
    _timestamp = value;
  }

  String get nombre => _nombre;

  set nombre(String value) {
    _nombre = value;
  }

  String? get descripcion => _descripcion;

  set descripcion(String? value) {
    _descripcion = value;
  }
}
