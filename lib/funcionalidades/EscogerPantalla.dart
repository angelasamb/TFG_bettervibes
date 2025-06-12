import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/pantallas/pantallaPrincipal.dart';
import '../pantallas/datosUsuario/pantallaCrearUnidadFamiliar.dart';
import '../pantallas/datosUsuario/pantallaDatosUsuario.dart';
import '../pantallas/registroUsuario/pantallaAutentification.dart';


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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => pantallaAutentification()),
        );
      } else {
        final idUsuario = usuarioFirebase.uid;
        final usuarioBaseDatos = await FirebaseFirestore.instance.collection(
            "Usuario").doc(idUsuario).get();
        if (usuarioBaseDatos.exists) {
          final datosUsuario = usuarioBaseDatos.data();
          final unidadRef = datosUsuario?["unidadFamiliarRef"];
          if (unidadRef is DocumentReference) {
            final unidadSnapshot = await unidadRef.get();
            if (unidadRef.toString().isNotEmpty && unidadSnapshot.exists) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PantallaPrincipal()),
              );
            }else{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PantallaCrearUnidadFamiliar()),
              );
            }
          }else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PantallaCrearUnidadFamiliar()),
            );
          }
        } else {
          Navigator.push(
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