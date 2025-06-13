import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaRanking.dart';
import 'package:tfg_bettervibes/widgets/MostrarTareas.dart';
import '../../widgets/BarChartRanking.dart';
import '../../widgets/ListaEventosDia.dart';

import 'package:flutter_svg/flutter_svg.dart';

class PantallaInicio extends StatefulWidget {
  final VoidCallback? irATareas;
  final VoidCallback? irAEventos;

  PantallaInicio({super.key, this.irATareas, this.irAEventos});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  DocumentReference? unidadFamiliarRef;


  @override
  void initState() {
    super.initState();
    cargarUnidadFamiliar();
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final usuario = FirebaseAuth.instance.currentUser!;
    final uid = usuario.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SvgPicture.asset(
            "assets/imagenes/fondo1.svg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TAREAS PARA HOY",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: widget.irATareas,
                        child: seccionCaja(
                          hijo: MostrarTareas(
                            unidadFamiliarRef: unidadFamiliarRef,
                            user: uid,
                            tipo: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        "EVENTOS DE ESTA SEMANA",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: widget.irAEventos,
                        child: seccionCaja(hijo: ListaEventosDia(fecha: hoy)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "PUNTUACIÓN SEMANAL",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PantallaRanking(),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              elevation: 2,
                              child: Container(
                                padding: EdgeInsets.all(20),
                                color: Colors.white,
                                child: Scrollbar(child: BarChartRanking()),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget seccionCaja({required Widget hijo}) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          elevation: 2,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Scrollbar(child: hijo),
          ),
        ),
      ),
    );
  }

  Future<void> cargarUnidadFamiliar() async {
    final referencia= await obtenerUnidadFamiliarRefActual();
    setState(() {
      unidadFamiliarRef = referencia;
    });
  }
}
