import 'package:tfg_bettervibes/clases/ClaseBase.dart';

class TipoTareas extends ClaseBase {
  String? _descripcion;
  String _nombre;
  num _puntuacion;

  TipoTareas({
    String? descripcion,
    required String nombre,
    required num puntuacion,
  }) : _descripcion = descripcion,
       _nombre = nombre,
       _puntuacion = puntuacion;

  @override
  Map<String, dynamic> toFirestore() {
   return{
     "descripcion":_descripcion,
     "nombre": _nombre,
     "puntuacion":_puntuacion
   };
  }

  factory TipoTareas.fromFirestore(Map<String, dynamic> map){
    return TipoTareas(
      descripcion: map["descripcion"] as String,
      nombre: map["nombre"] as String,
      puntuacion: map["puntuacion"] as num
    );
  }

  num get puntuacion => _puntuacion;

  set puntuacion(num value) {
    _puntuacion = value;
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
