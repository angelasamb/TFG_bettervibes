import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaRanking.dart';
import 'package:tfg_bettervibes/widgets/ListaTareasPorDiaYfinalizacion.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaTareas.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaEventos.dart';
import '../../funcionalidades/MainFunciones.dart';
import '../../widgets/BarChartRanking.dart';
import '../../widgets/ListaEventosDia.dart';

import 'package:flutter_svg/flutter_svg.dart';

class PantallaInicio extends StatelessWidget {
  final VoidCallback? irATareas;
  final VoidCallback? irAEventos;

  PantallaInicio({super.key, this.irATareas, this.irAEventos});

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
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
                        'TAREAS PARA HOY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: irATareas,
                        child: seccionCaja(
                          hijo: ListaTareasPorDiaYFinalizacion(
                            fecha: hoy,
                            mostrarRealizadas: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'EVENTOS DE ESTA SEMANA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: irAEventos,
                        child: seccionCaja(hijo: ListaEventosDia(fecha: hoy)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'PUNTUACIÓN SEMANAL',
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
}
