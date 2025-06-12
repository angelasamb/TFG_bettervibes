import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/pantallas/datosUsuario/pantallaDatosUsuario.dart';
import 'package:tfg_bettervibes/pantallas/datosUsuario/pantallaUnirteUnidadFamiliar.dart';
import 'package:tfg_bettervibes/pantallas/registroUsuario/pantallaAutentification.dart';
import 'package:tfg_bettervibes/widgets/personalizacion.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesCrearUnidadFamiliar.dart';
import 'package:tfg_bettervibes/pantallas/pantallaPrincipal.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PantallaCrearUnidadFamiliar extends StatelessWidget {
  const PantallaCrearUnidadFamiliar({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController contrasenaController = TextEditingController();
    final TextEditingController repetirContrasenaController =
        TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaAutentification(),
                      ),
                    );
                  },
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaDatosUsuario(),
                      ),
                    );
                  },
                ),
      ),
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
                  const SizedBox(height: 160),
                  Icon(
                    Icons.house,
                    size: 100,
                    color: Colors.gamaColores.shade200,
                  ),
                  Text(
                    "Crea tu propia unidad familiar",
                    style: TextStyle(fontFamily: "ERASMD", fontSize: 20),
                  ),

                  const SizedBox(height: 25),
                  plantillaField(
                    nombreController,
                    "Nombre de la unidad familiar",
                  ),
                  const SizedBox(height: 15),
                  plantillaField(
                    contrasenaController,
                    "Contraseña",
                    esContrasena: true,
                  ),
                  const SizedBox(height: 15),
                  plantillaField(
                    repetirContrasenaController,
                    "Repite la contraseña",
                    esContrasena: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(260, 40),
                    ),
                    onPressed: () async {
                      final nombreUF = nombreController.text.trim();
                      final contrasena = contrasenaController.text.trim();
                      final contrasenaRepetida =
                          repetirContrasenaController.text.trim();
                      if (nombreUF.isEmpty ||
                          contrasena.isEmpty ||
                          contrasenaRepetida.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tienes que rellenar todos los campos',
                            ),
                          ),
                        );
                        return;
                      }
                      if (contrasena != contrasenaRepetida) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Las contraseñas no son iguales"),
                          ),
                        );
                        return;
                      }
                      bool exito = await crearUnidadFamiliar(
                        nombreUF,
                        contrasena,
                      );
                      if (exito) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaPrincipal(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'ERROR: No se pudo crear la unidad familiar',
                            ),
                          ),
                        );
                        return;
                      }
                    },
                    child: const Text("Crear unidad familiar"),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      minimumSize: const Size(260, 40),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaUnirteUnidadfamiliar(),
                        ),
                      );
                    },
                    child: const Text("Unirse a una unidad familiar"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
