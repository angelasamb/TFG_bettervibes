import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfg_bettervibes/clases/Usuario.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';

final nombreColeccionUsuarios = 'Usuario';
Future<bool> CrearUsuarioBaseDeDatos(String colorEscogido, String imagenEscogida, String nombreEscogidod) async {
  try {
    final autentificacion = FirebaseAuth.instance;
    final baseDatos = FirebaseFirestore.instance;
    final usuarioConectado = autentificacion.currentUser;

    if (usuarioConectado == null) {
      print("ERROR: No hay usuario registrado, no se ha podido crear usuario");
      return false;
    }

      final idUsuario = usuarioConectado.uid;

      ColorElegido colorEnum = ColorElegido.values.firstWhere(
              (color) => color.name == colorEscogido,
          orElse: () => ColorElegido.AzulOscuro); // Color predeterminado

      Usuario usuarioNuevo = Usuario(admin: false, fotoPerfil: imagenEscogida, nombre: nombreEscogidod, colorElegido: colorEnum);

      await baseDatos.collection(nombreColeccionUsuarios).doc(idUsuario).set(usuarioNuevo.toFirestore());

      return(true);

  } catch (e) {
    print("ERROR: Error en FuncionesUsuario: $e");
    return(false);
  }
}

Future<bool> existeElUsuario() async {
  try {
    final baseDatos = FirebaseFirestore.instance;
    final autentificacion = FirebaseAuth.instance;
    final usuarioConectado = autentificacion.currentUser;

    if (usuarioConectado == null) {
      print("ERROR: No hay usuario registrado, no se ha podido crear usuario");
      return false;
    }

    final idUsuario = usuarioConectado.uid;

    final registro = await baseDatos.collection(nombreColeccionUsuarios).doc(idUsuario).get();
    return(true);
  } catch (e) {
    print("ERROR: Error en FuncionesUsuario: $e");
    return(false);
  }
}
