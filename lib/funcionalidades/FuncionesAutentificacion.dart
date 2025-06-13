import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Autentificacion {
  final FirebaseAuth _autentificacion = FirebaseAuth.instance;
  final GoogleSignIn _inicioGoogle = kIsWeb
  ? GoogleSignIn(clientId: '806584624803-0cble539totsqjma6kq9redu5o4dttd7.apps.googleusercontent.com')
      : GoogleSignIn();

  // INICIO  CON GOOGLE
  Future<UserCredential?> conectarConGoogle() async {
    try {
      final GoogleSignInAccount? usuarioGoogle = await _inicioGoogle.signIn();
      if (usuarioGoogle == null) return null; // Si cancela
      final GoogleSignInAuthentication autentificacionGoogle = await usuarioGoogle
          .authentication;

      final credenciales = GoogleAuthProvider.credential(
        accessToken: autentificacionGoogle.accessToken,
        idToken: autentificacionGoogle.idToken,
      );

      return await _autentificacion.signInWithCredential(credenciales);
    } catch (e) {
      print("ERROR: Inicio sesión con Google: $e");
      return null;
    }
  }

  // INICIO CON CORREO
  Future<UserCredential?> conectarConCorreo(String correo, String contrasena) async{
    try {
      return await _autentificacion.signInWithEmailAndPassword(email: correo, password: contrasena);
    }catch (e){
      print("ERROR: Inicio sesión con Correo: $e");
      return null;
    }
  }

  // REGISTRARSE CON CORREO
  Future<UserCredential?> registrarseConCorreo(String correo, String contrasena) async {
    try {
      return await _autentificacion.createUserWithEmailAndPassword(email: correo, password: contrasena);
    } on FirebaseAuthException catch (e) {
      print("ERROR: Registro con correo: ${e.code} - ${e.message}");
      throw e; // Lanzamos la excepción para manejarla fuera
    } catch (e) {
      print("ERROR Registro con correo: $e");
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    await _autentificacion.signOut();
    await _inicioGoogle.signOut();
  }
}
