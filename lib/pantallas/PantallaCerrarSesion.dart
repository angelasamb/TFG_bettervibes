import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesAutentificacion.dart';
import 'registroUsuario/PantallaAutentification.dart';

class PantallaCerrarSesion extends StatelessWidget {
  final Autentificacion _autentificacionFirebase = Autentificacion();

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi perfil"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (usuario != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundImage: usuario.photoURL != null
                    ? NetworkImage(usuario.photoURL!)
                    : null,
                child: usuario.photoURL == null ? const Icon(Icons.person, size: 40) : null,
              ),
              const SizedBox(height: 16),
              Text(
                usuario.displayName ?? "Usuario",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(usuario.email ?? ''),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: () async {
                await _autentificacionFirebase.cerrarSesion();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => PantallaAutentification()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Cerrar sesión"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () async {
            },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: const Text("Añadir usuario"),
            ),
          ],
        ),
      ),
    );
  }
}
