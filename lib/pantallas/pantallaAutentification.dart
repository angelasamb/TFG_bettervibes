import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesAutentificacion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCerrarSesion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaRegistroCorreo.dart';

class pantallaAutentification extends StatelessWidget {
  final Autentificacion _autentificacionFirebase = Autentificacion();
  String correo = "";
  String contrasena = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/imagenes/fondo1.png',fit: BoxFit.cover,
          ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Text('Better\n  Vibes',
                  style: TextStyle(
                      color: Color(0xFFB86DFF),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic
                  ),
                ),
                SizedBox(height: 10),
                Image.asset('assets/imagenes/iconos/iconoBetterVibes.png',
                  height: 120,
                ),

                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Correo',
                          ),
                          onChanged: (value) {
                            correo = value;
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          obscureText: true,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Contraseña',
                          ),
                          onChanged: (value) {
                            contrasena = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(260, 40),
                  ),
                  onPressed: () async{
                    final credencialesUsuario = await _autentificacionFirebase.conectarConCorreo(correo,contrasena);
                    if(credencialesUsuario != null) {
                      print('Inicion de sesión con Google: ${credencialesUsuario.user!.email}');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PantallaCerrarSesion()),
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
                  child: const Text('Iniciar sesión',
                    style: TextStyle(color: Colors.black),
                  ),
                ), // BOTON CORREO
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(260,40),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async{
                    final credencialesUsuario = await _autentificacionFirebase.conectarConGoogle();
                    if(credencialesUsuario != null) {
                      print('Inicio de sesión con Google: ${credencialesUsuario.user!.email}');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PantallaCerrarSesion()),
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/imagenes/iconos/iconoGoogle.png',
                    height: 24,
                    width: 24,
                  ),
                  label: const Text('Inicio de sesión con google',
                    style: TextStyle(color: Colors.black),
                  ),
                ),// BOTON GOOGLE
                TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaRegistroCorreo()));
                  },
                  child: Text('Regístrarme por correo')
                ), //BOTON REGISTRARSE CORREO
                SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}
