import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesAutentificacion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCerrarSesion.dart';

class pantallaAutentification extends StatelessWidget {
  final Autentificacion _autentificacionFirebase = Autentificacion();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/imagenes/fondo1.jpg',fit: BoxFit.cover,
          ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/imagenes/logo1.png',
                height: 120,
                ),
                const SizedBox(height: 60),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220,50),
                  ),
                  onPressed: () async{
                    final credencialesUsuario = await _autentificacionFirebase.conectarConGoogle();
                    if(credencialesUsuario != null) {
                      print('Inicio de sesión con Google: ${credencialesUsuario.user!.email}');
                      //TODO: Navegar a la ventana de personalización
                      // v v v BORRAR v v v
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PantallaCerrarSesion()),
                      );
                      // ^ ^ ^ BORRAR ^ ^ ^
                    }
                  },
                  icon: Image.asset('assets/imagenes/iconoGoogle.png',
                  height: 24,
                  ),
                  label: const Text('Iniciar con google'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 50),
                  ),
                  onPressed: () async{
                    final credencialesUsuario = await _autentificacionFirebase.conectarConCorreo("correo", "Contraseña");
                      if(credencialesUsuario != null) {
                        print('Inicion de sesión con Google: ${credencialesUsuario.user!.email}');
                        //TODO: Navegar a la ventana de personalización
                        // v v v BORRAR v v v
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PantallaCerrarSesion()),
                        );
                        // ^ ^ ^ BORRAR ^ ^ ^
                      };
                  },
                  child: const Text('Inicio sesión por correo',
                  style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}