import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/widgets/ListaTareasPorDiaYfinalizacion.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaTODO.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaEventos.dart';
import '../../funcionalidades/MainFunciones.dart';
import '../../widgets/ListaEventosDia.dart';

import 'package:flutter_svg/flutter_svg.dart';

class PantallaPagos extends StatefulWidget {
  const PantallaPagos({super.key});

  @override
  State<PantallaPagos> createState() => _PantallaPagos();
}

class _PantallaPagos extends State<PantallaPagos> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Pagos", style: TextStyle(fontSize: 40),),
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
