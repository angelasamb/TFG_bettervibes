import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/widgets/ListaTareasPorDiaYfinalizacion.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaTODO.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

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
                    child: ListaTareasPorDia(
                      fecha: hoy,
                      mostrarRealizadas: false,
                    ),
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
