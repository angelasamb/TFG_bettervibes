import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/widgets/ListaTareasPorDiaYfinalizacion.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaTODO.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaEventos.dart';
import '../../widgets/ListaEventosDia.dart';

class PantallaInicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaTODO()),
              );
            },
            child: const Text(
              'TAREAS HOY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                elevation: 2,
                child: Container(
                  color: Colors.white,
                  child: Scrollbar(
                    child: ListaTareasPorDiaYFinalizacion(
                      fecha: hoy,
                      mostrarRealizadas: false,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaEventos()),
              );
            },
            child: const Text(
              'EVENTOS HOY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 300,
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
    );
  }
}