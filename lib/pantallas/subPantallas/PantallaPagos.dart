import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaEditarPago.dart';
import '../../funcionalidades/MainFunciones.dart';

class PantallaPagos extends StatefulWidget {
  const PantallaPagos({super.key});

  @override
  State<PantallaPagos> createState() => _PantallaPagos();
}

class _PantallaPagos extends State<PantallaPagos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
          if (unidadFamiliarRef == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No se pudo obtener la unidad familiar")),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaEditarPago(),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Añadir nuevo pago",
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Pagos",
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
