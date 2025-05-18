import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesAutentificacion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCerrarSesion.dart';

class PantallaRegistroCorreo extends StatelessWidget {
  final Autentificacion _autentificacionFirebase = Autentificacion();

  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController contrasenaRepetidaController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, //para que la imagen de las lineas se vea detras de la appBar tambien
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, //para que se muestre el icono de vuelta atrás
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child:Image.asset(
            'assets/imagenes/fondo1.png',
            fit: BoxFit.cover,
            height: double.infinity,
            //stretches the widget to fill all available height within its parent container
            width: double.infinity,
          ), ),
          Center(
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              padding: const EdgeInsets.all(20),
              //padding uniforme de 20 pixeles en todos los lados
              children: [
                const SizedBox(height: 100), //empty space
                const Center(
                  child: Text(
                    'Better\n  Vibes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB86DFF),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    'assets/imagenes/iconos/iconoBetterVibes.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 30),
                //plantilla para los inputs, ahorro código
                _plantillaField(contrasenaController, "Correo"),
                const SizedBox(height: 10),
                _plantillaField(
                  contrasenaController,
                  "Contraseña",
                  esContrasena: true,
                ),
                const SizedBox(height: 10),
                _plantillaField(
                  contrasenaController,
                  "Repite la contraseña",
                  esContrasena: true,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(260, 40),
                  ),
                  onPressed: () async {
                    final correo = correoController.text;
                    final contrasena = contrasenaController.text;
                    final contrasenaRepetida = contrasenaRepetidaController.text;
                    if (contrasena == contrasenaRepetida) {
                      try {
                        final credencialesUsuario = await _autentificacionFirebase
                            .registrarseConCorreo(correo, contrasena);
                        if (credencialesUsuario != null) {
                          print(
                            'Registro por correo: ${credencialesUsuario.user!.email}',
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaCerrarSesion(),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        String mensaje = 'Error desconocido';
                        switch (e.code) {
                          case 'email-already-in-use':
                            mensaje = 'El correo ya está en uso.';
                            break;
                          case 'invalid-email':
                            mensaje = 'Correo inválido.';
                            break;
                          case 'weak-password':
                            mensaje = 'La contraseña es demasiado débil.';
                            break;
                          default:
                            mensaje = e.message ?? mensaje;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(mensaje),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Las contraseñas no coinciden'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Registrarse'),
                ), // BOTON REGISTRARSE
              ],
            ),
            )

          )
        ],

      ),
    );
  }

  Widget _plantillaField(
    TextEditingController controller,
    String hint, {
    bool esContrasena = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: esContrasena,
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
