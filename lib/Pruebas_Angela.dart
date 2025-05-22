import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCrearUnidadFamiliar.dart';
import 'package:tfg_bettervibes/pantallas/pantallaDatosUsuario.dart';
import 'package:tfg_bettervibes/pantallas/pantallaUnirteUnidadFamiliar.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Pantalla autentificación',
      initialRoute: '/',
      routes: {
        '/': (context) => PantallaCrearUnidadFamiliar()
      },
    );
  }
}