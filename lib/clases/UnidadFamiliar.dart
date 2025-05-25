import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/ClaseBase.dart';
import 'package:tfg_bettervibes/clases/TipoTareas.dart';

import 'Eventos.dart';
import 'Pagos.dart';
import 'Tareas.dart';

class UnidadFamiliar extends ClaseBase {
  List<Eventos> eventos =[];
  List<Pagos> pagos=[];
  List<Tareas> tareas=[];
  List<TipoTareas> tipoTareas=[];
  String _contrasenia;
  String _nombre;
  List<DocumentReference> _participantes;

  UnidadFamiliar({
    required String contrasenia,
    required String nombre,
    required List<DocumentReference> participantes,
  }) : _contrasenia = contrasenia,
       _nombre = nombre,
       _participantes = participantes;

  @override
  Map<String, dynamic> toFirestore() {
    return{
      "contrasenia": _contrasenia,
      "nombre":_nombre,
      "participantes":_participantes
    };
  }

  factory UnidadFamiliar.fromFirestore(Map<String, dynamic> map){
    return UnidadFamiliar(
      contrasenia: map["contrasenia"] as String,
      nombre: map["nombre"] as String,
      participantes: (map["participantes"] as List<dynamic>).cast<DocumentReference>()
    );
  }
  String get contrasenia => _contrasenia;

  set contrasenia(String value) {
    _contrasenia = value;
  }


  String get nombre => _nombre;

  set nombre(String value) {
    _nombre = value;
  }

  List<DocumentReference> get participantes => _participantes;

  set participantes(List<DocumentReference> value) {
    _participantes = value;
  }
}
