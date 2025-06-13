import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../funcionalidades/MainFunciones.dart';

enum ColorElegido{
  Rojo,
  Amarillo,
  VerdeAzulado,
  AzulClaro,
  AzulOscuro,
  Morado,
  Rosa,
  Gris;
}
Color getColorFromString(String color) {
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
ColorElegido? getColorElegidoFromString(String color) {
  switch (color) {
    case "Rojo":
      return ColorElegido.Rojo;
    case "Amarillo":
      return ColorElegido.Amarillo;
    case "VerdeAzulado":
      return ColorElegido.VerdeAzulado;
    case "AzulClaro":
      return ColorElegido.AzulClaro;
    case "AzulOscuro":
      return ColorElegido.AzulOscuro;
    case "Morado":
      return ColorElegido.Morado;
    case "Rosa":
      return ColorElegido.Rosa;
    case "Gris":
      return ColorElegido.Gris;
    default:
      return null;
  }
}

Future<List<ColorElegido>> listaColoresOcupados() async {
  final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
  final idUsuario = await FirebaseAuth.instance.currentUser?.uid;
  final snapshot = await FirebaseFirestore.instance.collection("Usuario").where("unidadFamiliarRef", isEqualTo: unidadFamiliarRef).get();
  return snapshot.docs.where((doc)=>doc.id!=idUsuario).map((doc)=> getColorElegidoFromString(doc["colorElegido"]as String)).whereType<ColorElegido>().toList();
}