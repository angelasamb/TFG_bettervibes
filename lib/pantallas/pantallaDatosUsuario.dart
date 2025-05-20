import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:tfg_bettervibes/funcionalidades/EscogerPantalla.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesUsuario.dart';
import '../clases/ColorElegido.dart';
import '../funcionalidades/FuncionesUsuario.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PantallaDatosUsuario extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PantallaDatosUsuarioState();
}

class _PantallaDatosUsuarioState extends State<PantallaDatosUsuario> {
  TextEditingController nombre = TextEditingController();
  final List<String> _rutasImagenes = [
    "assets/imagenes/fotoPerfil/icon_1.svg",
    "assets/imagenes/fotoPerfil/icon_2.svg",
    "assets/imagenes/fotoPerfil/icon_3.svg",
    "assets/imagenes/fotoPerfil/icon_4.svg",
    "assets/imagenes/fotoPerfil/icon_5.svg",
  ];
  Map<ColorElegido, Color> mapaColores = {
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

  String imagenSeleccionada = "";
  ColorElegido colorSeleccionado = ColorElegido.Rojo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              "assets/imagenes/fondo1.svg",
              fit: BoxFit.cover,
          ),),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: const EdgeInsets.all(40),
                children: [
                  const SizedBox(height: 40),
                  const Text(
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
                  _texto("Seleccione un icono"),
                  _plantillaSelector(_rutasImagenes, true),
                  _texto("Seleccione un color"),
                  _plantillaSelector(mapaColores.keys.toList(), false),
                  _texto("*Se podrá modificar en la configuracion del perfil"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.gamaColores.shade100,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(260, 40),
                    ),
                    onPressed: () async {
                      String nombreUsuario = nombre.text.trim();

                      if (nombreUsuario.isEmpty ||
                          imagenSeleccionada.isEmpty ||
                          colorSeleccionado == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Por favor, rellene todos los campos.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );

                      }else{
                        crearUsuarioBaseDeDatos(
                          colorSeleccionado.name,
                          imagenSeleccionada,
                          nombreUsuario,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EscogerPantalla(),
                          ),
                        );
                        
                      }
                    },
                    child: _texto("Guardar"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _texto(String mensaje) {
    return Text(
      mensaje,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      textAlign: TextAlign.left,
    );
  }

  Widget _plantillaField(TextEditingController controlador, String hint) {
    return Container(
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

  Widget _plantillaSelector(List listaRutas, bool esIcono) {
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
          seleccionada = ruta == imagenSeleccionada;
          contenido = SvgPicture.asset(ruta);
        } else if (ruta is ColorElegido) {
          final color = mapaColores[ruta]!;
          seleccionada = ruta == colorSeleccionado;
          contenido = Container(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        } else {
          contenido = const SizedBox();
        }
        ;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (ruta is String) {
                imagenSeleccionada = ruta;
              } else if (ruta is ColorElegido) {
                colorSeleccionado = ruta;
              }
            });
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
    );
  }
}