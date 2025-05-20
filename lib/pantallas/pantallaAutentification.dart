import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/EscogerPantalla.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesAutentificacion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCerrarSesion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaRegistroCorreo.dart';

class pantallaAutentification extends StatelessWidget {
  final Autentificacion _autentificacionFirebase = Autentificacion();

  TextEditingController correo = TextEditingController();
  TextEditingController contrasena = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/imagenes/fondo1.png', fit: BoxFit.cover),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 130),
                  Center(
                    child: Image.asset(
                      'assets/imagenes/iconos/logoFrase.png',
                      height: 50,
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
                  _plantillaField(correo, "Correo"),
                  const SizedBox(height: 20),
                  _plantillaField(contrasena, "Contraseña", esContrasena: true),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(260, 40),
                    ),
                    onPressed: () async {
                      final correoAux = correo.text;
                      final  contrasenaAux= contrasena.text;

                      final credencialesUsuario = await _autentificacionFirebase
                          .conectarConCorreo(correoAux, contrasenaAux);
                      if (credencialesUsuario != null) {
                        print(
                          'Inicion de sesión con Google: ${credencialesUsuario.user!.email}',
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaCerrarSesion(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Correo o contraseña incorrectos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),                   // BOTON CORREO

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(260, 40),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () async {
                      final credencialesUsuario =
                          await _autentificacionFirebase.conectarConGoogle();
                      if (credencialesUsuario != null) {
                        print(
                          'Inicio de sesión con Google: ${credencialesUsuario.user!.email}',
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
<<<<<<< Updated upstream
                            builder: (context) => PantallaCerrarSesion(),
=======
                            builder: (context) => EscogerPantalla(),
>>>>>>> Stashed changes
                          ),
                        );
                      }
                    },
                    icon: Image.asset(
                      'assets/imagenes/iconos/iconoGoogle.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text(
                      'Inicio de sesión con google',
                      style: TextStyle(color: Colors.black),
                    ),
                  ), // BOTON GOOGLE
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaRegistroCorreo(),
                        ),
                      );
                    },
                    child: Text('Regístrarme por correo'),
                  ), //BOTON REGISTRARSE CORREO
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
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
