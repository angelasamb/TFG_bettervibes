import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/widgets/MostrarTareas.dart';
import '../../../clases/ColorElegido.dart';
import '../../../funcionalidades/MainFunciones.dart';

class PantallaRanking extends StatefulWidget {
  TextEditingController nombreController = TextEditingController();
  String imagenSeleccionada = "";
  ColorElegido colorSeleccionado = ColorElegido.Rojo;

  PantallaRanking();

  @override
  State<PantallaRanking> createState() => _PantallaRankingState();
}

class _PantallaRankingState extends State<PantallaRanking> {
  DocumentReference? unidadFamiliarRef;
  String? user = FirebaseAuth.instance.currentUser?.uid;
  final todas = true;

  @override
  void initState() {
    super.initState();
    _cargarUnidadFamiliar();
  }

  Future<void> _cargarUnidadFamiliar() async {
    final ref = await obtenerUnidadFamiliarRefActual();
    setState(() {
      unidadFamiliarRef = ref;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (unidadFamiliarRef == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tareasRef = unidadFamiliarRef!.collection("Tareas");

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Ranking"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.gamaColores.shade500,
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start ,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Tareas realizadas:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Expanded(child:
                  MostrarTareas(
                    unidadFamiliarRef: unidadFamiliarRef,
                    user: user,
                    tipo: 3,
                    tareasRef: tareasRef,
                  ),)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
