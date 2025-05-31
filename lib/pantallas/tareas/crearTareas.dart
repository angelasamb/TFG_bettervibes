import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesUsuario.dart';

class CrearTareas extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _CrearTareasState();
}

class _CrearTareasState extends State<CrearTareas>{
  String? unidadFamiliarId;
 @override
  Future<void> initState() async {
    super.initState();
    unidadFamiliarId = await obtenerUnidadFamiliarId();

 }
  @override
  Widget build(BuildContext context) {
    final tipoTareasRef = FirebaseFirestore.instance
        .collection("UnidadFamiliar")
        .doc(unidadFamiliarId)
        .collection("TipoTareas");

    return Scaffold(
      extendBodyBehindAppBar: true,
      //para que la imagen de las lineas se vea detras de la appBar tambien
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        //para que se muestre el icono de vuelta atrás
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/imagenes/fondo1.svg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(40),
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Añade una tarea",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
