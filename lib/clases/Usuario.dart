import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/clases/ClaseBase.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';

class Usuario extends ClaseBase {
  // usar "_" -> private, para solo poder tener acceso mediante getters y setters
  bool _admin;
  num _balance;
  String _fotoPerfil;
  String _nombre;
  ColorElegido _colorElegido;
  DocumentReference _unidadFamiliarRef;

  Usuario({
    required bool admin,
    num balance=0.0,
    required String fotoPerfil,
    required String nombre,
    required ColorElegido colorElegido,
    required DocumentReference unidadFamiliarRef,
  }) : _admin = admin,
      _balance=balance,
       _fotoPerfil = fotoPerfil,
       _nombre = nombre,
       _colorElegido = colorElegido,
       _unidadFamiliarRef = unidadFamiliarRef;

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "admin": _admin,
      "balance": _balance,
      "fotoPerfil": _fotoPerfil,
      "nombre": _nombre,
      "colorElegido":_colorElegido.name,
      "unidadFamiliarRef":_unidadFamiliarRef
    };
  }

  factory Usuario.fromFirestore(Map<String, dynamic> map) {
    return Usuario(
      admin:map["admin"]as bool,
      balance: map["balance"] as num,
      fotoPerfil: map["fotoPerfil"] as String,
      nombre: map["nombre"] as String,
      //esta convirtiendo el string guardado en firestore al enum ColorElegido
      colorElegido: ColorElegido.values.byName(map["colorElegido"] as String),
      unidadFamiliarRef: map["unidadFamiliarRef"] as DocumentReference,
    );
  }

  bool get admin => _admin;

  set admin(bool value) {
    _admin = value;
  }

  num get balance => _balance;

  set balance(num value) {
    _balance = value;
  }

  String get fotoPerfil => _fotoPerfil;

  set fotoPerfil(String value) {
    _fotoPerfil = value;
  }

  String get nombre => _nombre;

  set nombre(String value) {
    _nombre = value;
  }

  ColorElegido get colorElegido => _colorElegido;

  set colorElegido(ColorElegido value) {
    _colorElegido = value;
  }

  DocumentReference get unidadFamiliarRef => _unidadFamiliarRef;

  set unidadFamiliarRef(DocumentReference value) {
    _unidadFamiliarRef = value;
  }

  @override
  String toString() {
    return 'Usuario{_admin: $_admin, _balance: $_balance, _fotoPerfil: $_fotoPerfil, _nombre: $_nombre, _colorElegido: $_colorElegido, _unidadFamiliarRef: $_unidadFamiliarRef}';
  }


}
