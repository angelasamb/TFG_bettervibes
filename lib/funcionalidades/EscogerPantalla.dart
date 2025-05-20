import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/pantallas/pantallaPrincipal.dart';
import '../pantallas/pantallaAutentification.dart';
import '../pantallas/pantallaCrearUnidadFamiliar.dart';
import '../pantallas/pantallaDatosUsuario.dart';


class EscogerPantalla extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _EscogerPantallaState();

}

class _EscogerPantallaState extends State<EscogerPantalla>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _estadoUsuario();
  }

  Future<void> _estadoUsuario() async {

      await Future.delayed(Duration(seconds: 1));
      final usuarioFirebase = FirebaseAuth.instance.currentUser;

      if (usuarioFirebase == null) {
        print("usuarioFirebase ==null");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => pantallaAutentification()),
        );
      } else {
        print(" else usuarioFirebase ==null");
        final idUsuario = usuarioFirebase.uid;
        final usuarioBaseDatos = await FirebaseFirestore.instance.collection(
            "Usuario").doc(idUsuario).get();
        if (usuarioBaseDatos.exists) {
          print("usuarioBaseDatos.exists");
          final datosUsuario = usuarioBaseDatos.data();
          if (datosUsuario?["unidadFamiliarRef"] != null) {
            print("datosUsuario?[]!=null");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PantallaPrincipal()),
            );
          } else {
            print("else datosUsuario?[]!=null");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PantallaCrearUnidadFamiliar()),
            );
          }
        } else {
          print("else usuarioBaseDatos.exists");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PantallaDatosUsuario()),
          );
        }
      }


  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

}