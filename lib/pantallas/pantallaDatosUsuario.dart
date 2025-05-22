import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:tfg_bettervibes/funcionalidades/EscogerPantalla.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesUsuario.dart';
import 'package:tfg_bettervibes/widgets/PlantillaSelector.dart';
import '../clases/ColorElegido.dart';
import '../funcionalidades/FuncionesUsuario.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/personalizacion.dart';

class PantallaDatosUsuario extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PantallaDatosUsuarioState();
}

class _PantallaDatosUsuarioState extends State<PantallaDatosUsuario> {
  TextEditingController nombre = TextEditingController();
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
            ),
          ),

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
                  plantillaField(nombre, "Nombre"),
                  const SizedBox(height: 10),
                  _texto("Seleccione un icono"),
                  PlantillaSelector(
                    esIcono: true,
                    itemSeleccionado: imagenSeleccionada,
                    onSelect: (value) {
                      setState(() {
                        imagenSeleccionada = value;
                      });
                    },
                  ),
                  _texto("Seleccione un color"),
                  PlantillaSelector(
                    esIcono: false,
                    itemSeleccionado: colorSeleccionado,
                    onSelect: (value) {
                      setState(() {
                        colorSeleccionado = value;
                      });
                    },
                  ),
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
                          colorSeleccionado.name.isEmpty ) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Por favor, rellene todos los campos.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
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

}
