import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/ClaseBase.dart';

class Pagos extends ClaseBase {
  String? _descripcion;
  DocumentReference _pagadorRef;
  List<DocumentReference> _participantes;
  num _precio;
  Timestamp _timestamp;


  Pagos({String? descripcion,
    required DocumentReference pagadorRef,
    required List<DocumentReference> participantes,
    required num precio,
    required Timestamp timestamp
  })
      : _descripcion=descripcion,
        _pagadorRef=pagadorRef,
        _participantes=participantes,
        _precio=precio,
        _timestamp=timestamp;

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "descripcion": _descripcion,
      "pagadorRef": _pagadorRef,
      "participantes": _participantes,
      "precio": _precio,
      "timestamp":_timestamp
    };
  }

  factory Pagos.fromFirestore(Map<String, dynamic> map){
    return Pagos
      (descripcion: map["descripcion"] as String?,
        pagadorRef: map["pagadorRef"] as DocumentReference,
        participantes: (map["participantes"] as List<dynamic>).cast<
            DocumentReference>(),
        precio: map["precio"],
        timestamp: map["timestamp"]
    );
  }

  Timestamp get timestamp => _timestamp;

  set timestamp(Timestamp value) {
    _timestamp = value;
  }

  num get precio => _precio;

  set precio(num value) {
    _precio = value;
  }

  List<DocumentReference> get participantes => _participantes;

  set participantes(List<DocumentReference> value) {
    _participantes = value;
  }

  DocumentReference get pagadorRef => _pagadorRef;

  set pagadorRef(DocumentReference value) {
    _pagadorRef = value;
  }

  String? get descripcion => _descripcion;

  set descripcion(String? value) {
    _descripcion = value;
  }


}