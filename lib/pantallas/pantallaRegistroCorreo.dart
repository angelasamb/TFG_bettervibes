import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesAutentificacion.dart';
import 'package:tfg_bettervibes/pantallas/pantallaCerrarSesion.dart';

class pantallaRegistroCorreo extends StatelessWidget {
  final Autentificacion _autentificacionFirebase = Autentificacion();

  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController contrasenaRepetidaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
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
                          controller: correoController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Correo',
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          obscureText: true,
                          style: TextStyle(color: Colors.black),
                          controller: contrasenaController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Contraseña',
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          obscureText: true,
                          style: TextStyle(color: Colors.black),
                          controller: contrasenaRepetidaController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Repite la contraseña',
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
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
                    final correo = correoController.text;
                    final contrasena = contrasenaController.text;
                    final contrasenaRepetida = contrasenaRepetidaController.text;
                    if (contrasena == contrasenaRepetida) {
                      try{
                        final credencialesUsuario = await _autentificacionFirebase.registrarseConCorreo(correo, contrasena);
                        if (credencialesUsuario != null) {
                          print(
                              'Registro por correo: ${credencialesUsuario
                                  .user!.email}');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                PantallaCerrarSesion()),
                          );
                        }
                      }
                      on FirebaseAuthException catch (e) {
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
                          content: Text('Las contraseñas no son iguales'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Registrarse',
                    style: TextStyle(color: Colors.black),
                  ),
                ), // BOTON REGISTRARSE
                SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}
