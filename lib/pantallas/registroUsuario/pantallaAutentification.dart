import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/EscogerPantalla.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesAutentificacion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/pantallas/registroUsuario/pantallaRegistroCorreo.dart';
import 'package:tfg_bettervibes/widgets/personalizacion.dart';

import '../datosUsuario/pantallaDatosUsuario.dart';


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
            child: SvgPicture.asset('assets/imagenes/fondo1.svg', fit: BoxFit.cover),
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
                  plantillaField(correo, "Correo"),
                  const SizedBox(height: 20),
                  plantillaField(contrasena, "Contraseña", esContrasena: true),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(260, 40),
                    ),
                    onPressed: () async {
                      final correoAux = correo.text;
                      final contrasenaAux = contrasena.text;

                      final credencialesUsuario = await _autentificacionFirebase
                          .conectarConCorreo(correoAux, contrasenaAux);
                      if (credencialesUsuario != null) {
                        print(
                          'Inicion de sesión con Google: ${credencialesUsuario.user!.email}',
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PantallaDatosUsuario(),
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
                  ), // BOTON CORREO
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(260, 40),
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Colors.black),
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
                            builder: (context) => EscogerPantalla(),
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
                  ),
                  const SizedBox(height: 5),// BOTON GOOGLE
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
}
