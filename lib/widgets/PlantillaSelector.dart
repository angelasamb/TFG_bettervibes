import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../clases/ColorElegido.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlantillaSelector extends StatelessWidget {
  final bool esIcono;
  final dynamic itemSeleccionado;
  final Function(dynamic seleccionado) onSelect;

  PlantillaSelector(
      {required this.esIcono, required this.itemSeleccionado, required this.onSelect});

  final List<String> _rutasImagenes = [
    "assets/imagenes/fotoPerfil/icon_1.svg",
    "assets/imagenes/fotoPerfil/icon_2.svg",
    "assets/imagenes/fotoPerfil/icon_3.svg",
    "assets/imagenes/fotoPerfil/icon_4.svg",
    "assets/imagenes/fotoPerfil/icon_5.svg",
  ];

  final Map<ColorElegido, Color> _mapaColores = {
    ColorElegido.Rojo: Color(0xff75181f),
    ColorElegido.Naranja: Color(0xfff36135),
    ColorElegido.Amarillo: Color(0xfff8df64),
    ColorElegido.Verde: Color(0xff7aa85e),
    ColorElegido.VerdeOscuro: Color(0xff366421),
    ColorElegido.AzulClaro: Color(0xff6cd9de),
    ColorElegido.AzulOscuro: Color(0xff173370),
    ColorElegido.Morado: Color(0xFF562A77),
    ColorElegido.Rosa: Color(0xFFD986E3),
    ColorElegido.Gris: Color(0xFF97919B),
  };

  @override
  Widget build(BuildContext context) {
    final listaRutas = esIcono ? _rutasImagenes : _mapaColores.keys.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listaRutas.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: esIcono ? 3 : 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),

      itemBuilder: (context, index) {
        final ruta = listaRutas[index];
        bool seleccionada = false;
        Widget contenido;

        if (ruta is String) {
          seleccionada = ruta == itemSeleccionado;
          contenido = SvgPicture.asset(ruta);
        } else if (ruta is ColorElegido) {
          final color = _mapaColores[ruta]!;
          seleccionada = ruta == itemSeleccionado;
          contenido = Container(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        } else {
          contenido = const SizedBox();
        }
        ;
        return GestureDetector(
          onTap: () => onSelect(ruta),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:

                seleccionada
                    ? Colors.gamaColores.shade50
                    : Colors.transparent,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: contenido,
          ),
        );
      },
    );
  }
}
