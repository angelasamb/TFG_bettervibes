import 'package:tfg_bettervibes/clases/ClaseBase.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';

class Usuario extends ClaseBase {
  // usar "_" -> private, para solo poder tener acceso mediante getters y setters

  String _nombre;
  ColorElegido _colorElegido;
  String _fotoPerfil;
  bool _admin;

  Usuario({required String id, required this._nombre, this._colorElegido } ):super(id: id);



  @override
  Map<String, dynamic> toMap() {
    return {
      "id":id,
      "email":_email,
      "nombre":_nombre,
      "colorElegido":_colorElegido.name,
    };
  }

  @override
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      map['id'] as String,
      map['email'] as String,
      map['nombre'] as String,
      ColorElegido.formarString(map['colorElegido'] as String),
    );
  }
}
