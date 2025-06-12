import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tfg_bettervibes/funcionalidades/EscogerPantalla.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("es_ES", null);
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
