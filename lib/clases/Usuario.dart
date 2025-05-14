import 'package:tfg_bettervibes/clases/ClaseBase.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';

class Usuario extends ClaseBase {
  // usar "_" -> private, para solo poder tener acceso mediante getters y setters

  final String _email;
  String _nombre;
  ColorElegido _colorElegido;

  Usuario(String id, String email, String nombre, ColorElegido colorElegido)
    : _email = email,
      _nombre = nombre,
      _colorElegido = colorElegido,
      super(id);

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
