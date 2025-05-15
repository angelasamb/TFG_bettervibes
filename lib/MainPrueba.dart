import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pantallas/pantallaAutentification.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
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