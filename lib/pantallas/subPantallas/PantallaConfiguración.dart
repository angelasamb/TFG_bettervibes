import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaModificarPerfil.dart';
import 'package:tfg_bettervibes/widgets/PlantillaSelector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/funcionalidades/SalirCambiarUnidadFamiliar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../registroUsuario/pantallaAutentification.dart';

class PantallaConfiguracion extends StatefulWidget {
  @override
  _PantallaConfiguracionState createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion> {
  TextEditingController nombreController = TextEditingController();
  String imagenSeleccionada = "";
  ColorElegido colorSeleccionado = ColorElegido.Rojo;

  String unidadFamiliarId = "";
  String contraseniaUnidad = "";
  bool mostrarContrasenia = false;

  bool cambiarContraseniaActivo = false;

  TextEditingController nuevaContraseniaController = TextEditingController();
  TextEditingController repetirContraseniaController = TextEditingController();

  DocumentReference? unidadFamiliarRef;
  bool esUsuarioActualAdmin = false;
  String nombreUnidadFamiliar = "";

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Configuración"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.gamaColores.shade500,
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      _seccionInvitacion(),
                      _seccionModificarPerfil(),
                      _listaUsuarios(),
                      _seccionSalirUnidadFamiliar(),
                      ElevatedButton(
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text("Confirmar cerrar sesión"),
                                  content: Text(
                                    "¿Seguro que quieres cerrar sesión?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text("Aceptar"),
                                    ),
                                  ],
                                ),
                          );

                          if (confirmar == true) {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => pantallaAutentification(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: Text("Cerrar sesión"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _cargarDatosUsuario() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user != null) {
      final doc = await firestore.collection("Usuario").doc(user.uid).get();
      final datos = doc.data();

      if (datos != null) {
        nombreController.text = datos["nombre"] ?? "";
        imagenSeleccionada = datos["fotoPerfil"] ?? "";
        colorSeleccionado = ColorElegido.values.firstWhere(
          (e) => e.name == datos["colorElegido"],
          orElse: () => ColorElegido.Rojo,
        );

        esUsuarioActualAdmin = datos['admin'] ?? false;

        final unidadRef = datos["unidadFamiliarRef"];
        if (unidadRef != null && unidadRef is DocumentReference) {
          unidadFamiliarRef = unidadRef;
          final unidadDoc = await unidadRef.get();

          final datosUnidad = unidadDoc.data() as Map<String, dynamic>?;
          unidadFamiliarId = unidadRef.id;
          contraseniaUnidad = datosUnidad?["contrasenia"] ?? "";
          nombreUnidadFamiliar = datosUnidad?["nombre"] ?? "";
        }
        setState(() {});
      }
    }
  }

  Widget _seccionInvitacion() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Invita a alguien",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("ID Unidad Familiar:"),
            Row(
              children: [
                Expanded(child: SelectableText(unidadFamiliarId)),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: unidadFamiliarId));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("ID copiado")));
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "Contraseña: ${mostrarContrasenia ? contraseniaUnidad : '********'}",
                ),
                IconButton(
                  icon: Icon(
                    mostrarContrasenia
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarContrasenia = !mostrarContrasenia;
                    });
                  },
                ),
              ],
            ),
            cambiarContraseniaActivo
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text("Nueva Contraseña:"),
                    TextField(
                      controller: nuevaContraseniaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Repetir Contraseña:"),
                    TextField(
                      controller: repetirContraseniaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            cambiarContraseniaActivo = false;
                            nuevaContraseniaController.clear();
                            repetirContraseniaController.clear();
                            setState(() {});
                          },
                          child: Text("Cancelar"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _cambiarContraseniaUnidadFamiliar,
                          child: Text("Guardar"),
                        ),
                      ],
                    ),
                  ],
                )
                : TextButton(
                  onPressed: () {
                    cambiarContraseniaActivo = true;
                    setState(() {});
                  },
                  child: Text("Cambiar contraseña"),
                ),
          ],
        ),
      ),
    );
  }

  Widget _listaUsuarios() {
    if (unidadFamiliarRef == null) {
      return Center(child: Text("No hay unidad familiar seleccionada"));
    }

    final firestore = FirebaseFirestore.instance;

    final usuariosStream =
        firestore
            .collection("Usuario")
            .where("unidadFamiliarRef", isEqualTo: unidadFamiliarRef)
            .snapshots();
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Usuarios en $nombreUnidadFamiliar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: usuariosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("No hay usuarios en esta unidad familiar");
                }

                final usuariosDocs = snapshot.data!.docs;

                return Column(
                  children:
                      usuariosDocs.map((doc) {
                        final datos = doc.data() as Map<String, dynamic>;
                        final nombre = datos['nombre'] ?? "Sin nombre";
                        final foto = datos['fotoPerfil'] ?? "";
                        final color = datos["colorElegido"];
                        final colorElegido = getColorFromString(color);
                        final esAdmin = datos['admin'] ?? false;
                        final uid = doc.id;

                        final esUsuarioActual =
                            FirebaseAuth.instance.currentUser?.uid == uid;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading:
                                foto.isNotEmpty
                                    ? (foto.endsWith(".svg")
                                        ? CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          child: SvgPicture.asset(
                                            foto,
                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                          ),
                                        )
                                        : CircleAvatar(
                                          backgroundImage: AssetImage(foto),
                                        ))
                                    : CircleAvatar(child: Icon(Icons.person)),
                            title: Text(
                              nombre,
                              style: TextStyle(color: colorElegido),
                            ),
                            subtitle: Text(
                              esAdmin ? "Administrador" : "Usuario",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (esUsuarioActualAdmin &&
                                    !esAdmin &&
                                    !esUsuarioActual)
                                  IconButton(
                                    icon: Icon(
                                      Icons.admin_panel_settings,
                                      color: Colors.green,
                                    ),
                                    tooltip: "Hacer admin",
                                    onPressed: () async {
                                      await actualizarAdmin(uid, true);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "$nombre ahora es admin",
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                if (esUsuarioActualAdmin &&
                                    esAdmin &&
                                    !esUsuarioActual)
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_moderator,
                                      color: Colors.orange,
                                    ),
                                    tooltip: "Quitar admin",
                                    onPressed: () async {
                                      bool esAdmin = await sigueSiendoAdmin();
                                      if (esAdmin) {
                                        await actualizarAdmin(uid, false);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Se quitó admin a $nombre",
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    },
                                  ),

                                if (esUsuarioActualAdmin && !esUsuarioActual)
                                  IconButton(
                                    icon: Icon(
                                      Icons.exit_to_app,
                                      color: Colors.red,
                                    ),
                                    tooltip: "Expulsar usuario",
                                    onPressed: () async {
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: Text(
                                                "Confirmar expulsión",
                                              ),
                                              content: Text(
                                                "¿Seguro que quieres expulsar a $nombre?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text("Cancelar"),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: Text("Expulsar"),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirmar == true) {
                                        bool esAdmin = await sigueSiendoAdmin();
                                        if (esAdmin) {
                                          await expulsarUsuario(
                                            context,
                                            doc.reference,
                                            unidadFamiliarRef,
                                          );
                                        }
                                        return;
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionSalirUnidadFamiliar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        onPressed: () async {
          final confirmar = await showDialog<bool>(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: Text("Confirmar salir unidad familiar"),
                  content: Text(
                    "¿Seguro que quieres salir de la unidad familiar? Esta acción no se puede deshacer.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Salir"),
                    ),
                  ],
                ),
          );
          if (confirmar == true) {
            await salirUnidadFamiliar(context, unidadFamiliarRef!);
          }
        },
        child: Text("Salir de la unidad familiar"),
      ),
    );
  }

  Future<bool> sigueSiendoAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final userSnapshot =
        await FirebaseFirestore.instance.collection('Usuario').doc(uid).get();
    final data = userSnapshot.data();
    return data != null && data['admin'] == true;
  }

  Future<void> _cambiarContraseniaUnidadFamiliar() async {
    final nueva = nuevaContraseniaController.text.trim();
    final repetir = repetirContraseniaController.text.trim();

    await cambiarContraseniaUnidadFamiliar(
      context: context,
      nuevaContrasenia: nueva,
      repetirContrasenia: repetir,
      unidadFamiliarRef: unidadFamiliarRef,
      onExito: () {
        contraseniaUnidad = nueva;
        cambiarContraseniaActivo = false;
        nuevaContraseniaController.clear();
        repetirContraseniaController.clear();
        setState(() {});
      },
    );
  }

  Widget _seccionModificarPerfil() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: ElevatedButton(
        child: Text("Modificar perfil"),
        onPressed: () async {
          await _cargarDatosUsuario(); //si no hay que refrescar la pagina en la que estas para que se muestren los cambios desntro dew modificar perfil
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PantallaModificarPerfil(
                    nombreController,
                    imagenSeleccionada,
                    colorSeleccionado,
                  ),
            ),
          );
        },
      ),
    );
  }
}
