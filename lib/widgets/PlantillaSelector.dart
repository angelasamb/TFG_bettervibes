import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import '../clases/ColorElegido.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlantillaSelector extends StatefulWidget {
  final bool esIcono;
  final dynamic itemSeleccionado;
  final Function(dynamic seleccionado) onSelect;

  PlantillaSelector({
    required this.esIcono,
    this.itemSeleccionado,
    required this.onSelect,
  });

  @override
  State<PlantillaSelector> createState() => _PlantillaSelectorState();
}

class _PlantillaSelectorState extends State<PlantillaSelector> {
  final List<String> _rutasImagenes = [
    "assets/imagenes/fotoPerfil/icon_1.svg",
    "assets/imagenes/fotoPerfil/icon_2.svg",
    "assets/imagenes/fotoPerfil/icon_3.svg",
    "assets/imagenes/fotoPerfil/icon_4.svg",
    "assets/imagenes/fotoPerfil/icon_5.svg",
  ];

  final Map<ColorElegido, Color> mapaColores = {
    ColorElegido.Rojo: Color(0xffd73027),
    ColorElegido.Amarillo: Color(0xFFFFFF00),
    ColorElegido.VerdeAzulado: Color(0xff008080),
    ColorElegido.AzulClaro: Color(0xFF87CEEB),
    ColorElegido.AzulOscuro: Color(0xff173370),
    ColorElegido.Morado: Color(0xFF762A83),
    ColorElegido.Rosa: Color(0xFFD986E3),
    ColorElegido.Gris: Color(0xFF97919B),
  };

  List<ColorElegido> coloresOcupados = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cargarColoresOcupados();
  }

  @override
  Widget build(BuildContext context) {
    final listaRutas =
        widget.esIcono ? _rutasImagenes : mapaColores.keys.toList();
    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listaRutas.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.esIcono ? 3 : 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),

        itemBuilder: (context, index) {
          final ruta = listaRutas[index];
          bool seleccionada = false;
          Widget contenido;
          bool estaOcupado = false;

          if (ruta is String) {
            seleccionada = ruta == widget.itemSeleccionado;
            contenido = SvgPicture.asset(ruta);
          } else if (ruta is ColorElegido) {
            final color = mapaColores[ruta]!;
            seleccionada = ruta == widget.itemSeleccionado;

            estaOcupado = coloresOcupados.contains(ruta);
            contenido = Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (estaOcupado)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    child: Center(child: Icon(Icons.lock, color: Colors.white)),
                  ),
              ],
            );
          } else {
            contenido = const SizedBox();
          }
          ;
          return GestureDetector(
            onTap: () {
              if (ruta is ColorElegido && !estaOcupado) {
                widget.onSelect(ruta);
              }
              if (ruta is String) {
                widget.onSelect(ruta);
              }
            },
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
      ),
    );
  }

  Future<void> cargarColoresOcupados() async {
    final lista = await listaColoresOcupados();
    setState(() {
      coloresOcupados = lista;
    });
  }
}
