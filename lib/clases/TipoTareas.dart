import 'package:tfg_bettervibes/clases/ClaseBase.dart';

class TipoTareas extends ClaseBase {
  String _nombre;
  num _puntuacion;

  TipoTareas({
    required String nombre,
    required num puntuacion,
  }) : _nombre = nombre,
       _puntuacion = puntuacion;

  @override
  Map<String, dynamic> toFirestore() {
   return{
     "nombre": _nombre,
     "puntuacion":_puntuacion
   };
  }

  factory TipoTareas.fromFirestore(Map<String, dynamic> map){
    return TipoTareas(
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





}
