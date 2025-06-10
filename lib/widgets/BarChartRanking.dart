import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';

class BarChartRanking extends StatefulWidget {
  @override
  State<BarChartRanking> createState() => _BarChartRankingState();
}

class _BarChartRankingState extends State<BarChartRanking> {
  DocumentReference? unidadFamiliarRef;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, int> datosPuntuacion = {};

  @override
  void initState() {
    super.initState();
    cargarUnidadFamiliarRef();
  }

  @override
  Widget build(BuildContext context) {
    if (unidadFamiliarRef == null) {
      return Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<QuerySnapshot>(
      future:
          _firestore
              .collection("Usuario")
              .where("unidadFamiliarRef", isEqualTo: unidadFamiliarRef!)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("No hay datos"));
        final docs = snapshot.data!.docs;
        final List<String> nombres = [];
        final List<int> puntuaciones = [];
        for (var doc in docs) {
          nombres.add(doc["nombre"]);
          puntuaciones.add(doc["puntuacion"]);
        }
        final List<BarChartGroupData> barGroups = [];
        for (int i = 0; i < puntuaciones.length; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              showingTooltipIndicators: [0],
              barRods: [
                BarChartRodData(
                  toY: puntuaciones[i].toDouble(),
                  color: Colors.gamaColores.shade200,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }

        final maxY = puntuaciones.reduce((a, b) => a > b ? a : b);
        final maxYmultiplo5 = multiploCinco(maxY);

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            maxY: maxYmultiplo5.toDouble(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    return i >= 0 && i < nombres.length
                        ? Text(nombres[i])
                        : const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            barGroups: barGroups,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor:(group)=> Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 0,
                getTooltipItem: (grupo, indiceGrupo, rod, indiceRod) {
                  return BarTooltipItem(
                    rod.toY.toInt().toString(),
                    TextStyle(color: Colors.black),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> cargarUnidadFamiliarRef() async {
    final ref = await obtenerUnidadFamiliarRefActual();
    setState(() {
      unidadFamiliarRef = ref;
    });
  }

  int multiploCinco(int maxY) {
    return ((maxY + 4) ~/ 5) *
        5; // redondea hacia arriba al múltiplo de 5 más cercano
  }
}
