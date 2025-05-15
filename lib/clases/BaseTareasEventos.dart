import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/ClaseBase.dart';

abstract class BaseTareasEventos extends ClaseBase{
  String _id;
  String _nombre;
  String _descripcion;
  Timestamp _timestamp;

  BaseTareasEventos(super.id);

  @override
  Map<String, dynamic> toMap() {
    return {
      "id":id,
      "nombre":_nombre,
      "colorElegido":_colorElegido.name,
    };
  }

}