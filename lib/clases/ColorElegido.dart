import 'package:flutter/material.dart';

enum ColorElegido{
  Rojo,
  Naranja,
  Amarillo,
  Verde,
  AzulClaro,
  AzulOscuro,
  Morado,
  Rosa,
  VerdeOscuro,
  Gris;
}
Color getColorFromEnum(String color) {
  switch (color) {
    case "Rojo":
      return Color(0xff75181f);
    case "Naranja":
      return Color(0xfff36135);
    case "Amarillo":
      return Color(0xfff8df64);
    case "Verde":
      return Color(0xff7aa85e);
    case "AzulClaro":
      return Color(0xff6cd9de);
    case "AzulOscuro":
      return Color(0xff173370);
    case "Morado":
      return Color(0xFF562A77);
    case "Rosa":
      return Color(0xFFD986E3);
    case "VerdeOscuro":
      return Color(0xff366421);
    case "Gris":
      return Color(0xFF97919B);
    default:
      return Color(0xFF97919B);
  }
}
