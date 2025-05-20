import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/ClaseBase.dart';

class Tareas extends ClaseBase {
  bool _realizada;
  Timestamp _timestamp;
  DocumentReference _tipoTareaRef;
  DocumentReference _usuarioRef;

  Tareas({
    required bool realizada,
    required Timestamp timestamp,
    required DocumentReference tipoTareaRef,
    required DocumentReference usuarioRef,
  }) : _realizada = realizada,
        _timestamp = timestamp,
       _tipoTareaRef = tipoTareaRef,
       _usuarioRef = usuarioRef;

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "realizada": _realizada,
      "timestamp": _timestamp,
      "tipotareaRef": _tipoTareaRef,
      "usuarioRef": _usuarioRef,
    };
  }

  factory Tareas.fromFirestore(Map<String, dynamic> map) {
    return Tareas(
      realizada: map["realizada"] as bool,
      timestamp: map["timestamp"] as Timestamp,
      tipoTareaRef: map["tipoTareas"] as DocumentReference,
      usuarioRef: map["usuarioRef"] as DocumentReference,
    );
  }

  DocumentReference get usuarioRef => _usuarioRef;

  set usuarioRef(DocumentReference value) {
    _usuarioRef = value;
  }

  DocumentReference get tipoTareaRef => _tipoTareaRef;

  set tipoTareaRef(DocumentReference value) {
    _tipoTareaRef = value;
  }

  Timestamp get timestamp => _timestamp;

  set timestamp(Timestamp value) {
    _timestamp = value;
  }

  bool get realizada => _realizada;

  set realizada(bool value) {
    _realizada = value;
  }

  @override
  String toString() {
    return 'Tareas{_realizada: $_realizada, _timestamp: $_timestamp, _tipoTareaRef: $_tipoTareaRef, _usuarioRef: $_usuarioRef}';
  }
}
