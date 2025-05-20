import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tfg_bettervibes/funcionalidades/EscogerPantalla.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCerrarSesion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaDatosUsuario.dart';
import 'package:tfg_bettervibes/pantallas/pantallaUnidadFamiliar.dart';
import 'pantallas/pantallaAutentification.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pantalla Registro",
      home: EscogerPantalla(),
    );
  }
}
