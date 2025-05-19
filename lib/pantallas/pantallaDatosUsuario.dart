import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class PantallaDatosUsuario extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _PantallaDatosUsuarioState();
}
class _PantallaDatosUsuarioState extends State<PantallaDatosUsuario>{
TextEditingController nombre = TextEditingController();
  final List<String> _rutasImagenes = [
    "assets/imagenes/fotoPerfil/icon_1.svg",
    "assets/imagenes/fotoPerfil/icon_2.svg",
    "assets/imagenes/fotoPerfil/icon_3.svg",
    "assets/imagenes/fotoPerfil/icon_4.svg",
    "assets/imagenes/fotoPerfil/icon_5.svg",
  ];
  String? imagenSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset("assets/imagenes/fondo1.svg", fit: BoxFit.cover),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 130),
                  Text(
                    "Datos Usuario",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // size in logical pixels
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  _plantillaField(nombre, "Nombre"),
                  const SizedBox(height: 10),
                  Text(
                    "Seleccione una imagen: ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rutasImagenes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      final ruta = _rutasImagenes[index];
                      final seleccionada = ruta == imagenSeleccionada;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            imagenSeleccionada=ruta;
                          });
                          print("imagen seleccionada:$imagenSeleccionada");
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
                          child: SvgPicture.asset(ruta),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plantillaField(TextEditingController controlador, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controlador,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

}
