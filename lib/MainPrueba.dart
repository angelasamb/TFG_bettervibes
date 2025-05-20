import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< Updated upstream
=======
import 'package:tfg_bettervibes/funcionalidades/EscogerPantalla.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCerrarSesion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaDatosUsuario.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCrearUnidadFamiliar.dart';
>>>>>>> Stashed changes
import 'pantallas/pantallaAutentification.dart';
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
        '/': (context) => pantallaAutentification()
      },
  );
}
}