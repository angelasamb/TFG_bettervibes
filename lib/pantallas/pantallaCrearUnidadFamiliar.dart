import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/widgets/personalizacion.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesCrearUnidadFamiliar.dart';
import 'package:tfg_bettervibes/pantallas/pantallaPrincipal.dart';
import 'package:tfg_bettervibes/pantallas/pantallaUnirteUnidadFamiliar.dart';

class PantallaCrearUnidadFamiliar extends StatelessWidget {
  const PantallaCrearUnidadFamiliar({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController contrasenaController = TextEditingController();
    final TextEditingController repetirContrasenaController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.house,
              size: 100,
              color: Colors.gamaColores.shade400,
            ),
            const SizedBox(height: 25),
            plantillaField(nombreController, "Nombre de la unidad familiar"),
            const SizedBox(height: 15),
            plantillaField(contrasenaController, "Contraseña", esContrasena: true),
            const SizedBox(height: 15),
            plantillaField(repetirContrasenaController, "Repite la contraseña", esContrasena: true),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(260, 40)
              ),
              onPressed: () async {
                final nombreUF = nombreController.text.trim();
                final contrasena = contrasenaController.text.trim();
                final contrasenaRepetida = repetirContrasenaController.text.trim();
                if (nombreUF.isEmpty || contrasena.isEmpty || contrasenaRepetida.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tienes que rellenar todos los campos')),
                  );
                  return;
                }
                if (contrasena != contrasenaRepetida) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Las contraseñas no son iguales')),
                  );
                  return;
                }
                bool exito = await crearUnidadFamiliar(nombreUF, contrasena);
                if (exito) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaPrincipal()));
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ERROR: No se pudo crear la unidad familiar')),
                  );
                  return;
                }
              },
              child: const Text('Crear unidad familiar'),
            ),
            SizedBox(height: 15,),
            TextButton(
              style: TextButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  minimumSize: const Size(260, 40)
              ),
              onPressed: () async {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PantallaUnirteUnidadfamiliar()));
              },
              child: const Text('Unirse a una unidad familiar'),
            )
          ],

        ),
      ),
    );
  }
}
