import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Autentificacion {
  final FirebaseAuth _autentificacion = FirebaseAuth.instance;
  final GoogleSignIn _inicioGoogle = GoogleSignIn();

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
      print('ERROR: Inicio sesión con Google: $e');
      return null;
    }
  }

  // INICIO CON CORREO
  Future<UserCredential?> conectarConCorreo(String correo, String contrasena) async {
    try {
      return await _autentificacion.signInWithEmailAndPassword(email: correo, password: contrasena);
    }catch (e){
      print('ERROR: Inicio sesión con Correo: $e');
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    await _autentificacion.signOut();
    await _inicioGoogle.signOut();
  }
}
