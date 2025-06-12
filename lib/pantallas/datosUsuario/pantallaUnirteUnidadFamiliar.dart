import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesCrearUnidadFamiliar.dart';
import '../../clases/ColorElegido.dart';
import '../../widgets/personalizacion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaPrincipal.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PantallaUnirteUnidadfamiliar extends StatelessWidget {
  const PantallaUnirteUnidadfamiliar({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController contrasenaController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: Navigator.canPop(context),
        leading:
            Navigator.canPop(context)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
                : null,
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
                    color: Colors.gamaColores.shade400,
                  ),
                  const SizedBox(height: 25),
                  plantillaField(idController, "id de la unidad familiar"),
                  const SizedBox(height: 15),
                  plantillaField(
                    contrasenaController,
                    "Contraseña",
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
                      final nombreUF = idController.text.trim();
                      final contrasena = contrasenaController.text.trim();
                      if (nombreUF.isEmpty || contrasena.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tienes que rellenar todos los campos',
                            ),
                          ),
                        );
                        return;
                      }
                      bool exito = await unirseUnidadFamiliar(
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
                              'ERROR: No se pudo unir a la unidad familiar',
                            ),
                          ),
                        );
                        return;
                      }
                    },
                    child: const Text("Unirse a unidad familiar"),
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
