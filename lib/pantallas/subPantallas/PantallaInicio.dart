import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/widgets/ListaTareasPorDiaYfinalizacion.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaTODO.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaEventos.dart';
import '../../funcionalidades/MainFunciones.dart';
import '../../widgets/ListaEventosDia.dart';

import 'package:flutter_svg/flutter_svg.dart';

class PantallaInicio extends StatelessWidget {

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PantallaTODO(),
                          ),
                        );
                      },
                      child: const Text(
                        'TAREAS HOY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    seccionCaja(
                      hijo: ListaTareasPorDiaYFinalizacion(
                        fecha: hoy,
                        mostrarRealizadas: false,
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PantallaEventos(),
                          ),
                        );
                      },
                      child: const Text(
                        'EVENTOS HOY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    seccionCaja(hijo: ListaEventosDia(fecha: hoy)),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PantallaEventos(),
                          ),
                        );
                      },
                      child: const Text(
                        'RANKING',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          elevation: 2,
                          child: Container(
                            color: Colors.white,
                            child: Scrollbar(
                              child: ListaEventosDia(fecha: hoy),
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
          child: Container(color: Colors.white, child: Scrollbar(child: hijo)),
        ),
      ),
    );
  }
}
