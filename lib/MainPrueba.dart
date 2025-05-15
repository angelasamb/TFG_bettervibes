import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/main.dart';
import 'pantallas/pantallaAutentification.dart';
void main(){
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
        '/': (context) => const pantallaAutentification()
      },
  );
}
}