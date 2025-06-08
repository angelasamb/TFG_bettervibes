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
  VerdeAzulado,
  Gris;
}
Color getColorFromEnum(String color) {
  switch (color) {
    case "Rojo":
      return Color(0xffd73027);
    case "Amarillo":
      return Color(0xFFFFFF00);
    case "VerdeAzulado":
      return Color(0xff008080);
    case "AzulClaro":
      return Color(0xFF87CEEB);
    case "AzulOscuro":
      return Color(0xff173370);
    case "Morado":
      return Color(0xFF762A83);
    case "Rosa":
      return Color(0xFFD986E3);
    case "Gris":
      return Color(0xFF97919B);
    default:
      return Color(0xFF97919B);
  }
}
