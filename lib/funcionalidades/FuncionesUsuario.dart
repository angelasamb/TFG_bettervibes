import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfg_bettervibes/clases/Usuario.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';

final nombreColeccionUsuarios = "Usuario";

Future<bool> crearUsuarioBaseDeDatos(
  String imagenEscogida,
  String nombreEscogido,
) async {
  try {
    final autentificacion = FirebaseAuth.instance;
    final baseDatos = FirebaseFirestore.instance;
    final usuarioConectado = autentificacion.currentUser;

    if (usuarioConectado == null) {
      print("ERROR: No hay usuario registrado, no se ha podido crear usuario");
      return false;
    }

    final idUsuario = usuarioConectado.uid;

    Usuario usuarioNuevo = Usuario(
      admin: false,
      fotoPerfil: imagenEscogida,
      nombre: nombreEscogido,
      colorElegido: ColorElegido.Gris,
    );

    await baseDatos
        .collection(nombreColeccionUsuarios)
        .doc(idUsuario)
        .set(usuarioNuevo.toFirestore());

    return (true);
  } catch (e) {
    print("ERROR: Error en FuncionesUsuario: $e");
    return (false);
  }
}

Future<bool> existeElUsuario() async {
  try {
    final autentificacion = FirebaseAuth.instance;
    final usuarioConectado = autentificacion.currentUser;

    if (usuarioConectado == null) {
      print("ERROR: No hay usuario registrado, no se ha podido crear usuario");
      return false;
    }
    return (true);
  } catch (e) {
    print("ERROR: Error en FuncionesUsuario: $e");
    return (false);
  }
}
Future<List<String>> obtenerNombresUsuarios(DocumentReference ref1, DocumentReference ref2) async {
  final snapshot1 = await ref1.get();
  final snapshot2 = await ref2.get();

  final nombre1 = (snapshot1.data() as Map<String, dynamic>)["nombre"] ?? "Desconocido";
  final nombre2 = (snapshot2.data() as Map<String, dynamic>)["nombre"] ?? "Desconocido";
  return [nombre1, nombre2];
}

