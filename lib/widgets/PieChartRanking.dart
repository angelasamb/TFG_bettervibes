import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';

class PieChartRanking extends StatefulWidget {
  DocumentReference? unidadFamiliarRef;

  PieChartRanking({this.unidadFamiliarRef});

  @override
  State<PieChartRanking> createState() => _PieChartRankingState();
}

class _PieChartRankingState extends State<PieChartRanking> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    cargarUnidadFamiliarRef();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> usuarioGanador = [];
    if (widget.unidadFamiliarRef == null) {
      return Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection("Usuario")
              .where("unidadFamiliarRef", isEqualTo: widget.unidadFamiliarRef!)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("No hay datos"));

        final usuarios = snapshot.data!.docs;
        final List<String> nombres = [];
        final List<int> puntuaciones = [];
        final List<Color> colores = [];
        int maxPuntuacion = 0;
        for (var usuario in usuarios) {
          nombres.add(usuario["nombre"]);
          colores.add(getColorFromString(usuario["colorElegido"]));
          final puntuacion = usuario["puntuacion"] ?? 0;
          puntuaciones.add(puntuacion);
          if (maxPuntuacion < puntuacion) {
            usuarioGanador = [usuario];
            maxPuntuacion=puntuacion;
          } else if (puntuacion == maxPuntuacion) {
            usuarioGanador.add(usuario);
          }
        }

        final totalPuntuacion = puntuaciones.fold<int>(0, (a, b) => a + b);
        if (totalPuntuacion == 0) {
          return Center(child: Text("No hay puntuaciones disponibles"));
        }

        final List<PieChartSectionData> sections = [];
        for (int i = 0; i < puntuaciones.length; i++) {
          final porcentaje = puntuaciones[i] / totalPuntuacion * 100;

          sections.add(
            PieChartSectionData(
              color: colores[i % colores.length].withOpacity(0.7),
              value: puntuaciones[i].toDouble(),
              title: '${porcentaje.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(sections: sections, centerSpaceRadius: 40),
                  ),
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(nombres.length, (index) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          //cuadradito de color
                          width: 16,
                          height: 16,
                          color: colores[index % colores.length].withOpacity(
                            0.7,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(nombres[index]),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 10),
                Text(
                  usuarioGanador.length == 1
                      ? "Va ganando: ${usuarioGanador.first["nombre"]}"
                      : "Empate entre: ${usuarioGanador.map((u) => u["nombre"]).join(", ")}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.gamaColores.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> cargarUnidadFamiliarRef() async {
    final ref = await obtenerUnidadFamiliarRefActual();
    setState(() {
      widget.unidadFamiliarRef = ref!;
    });
  }
}
