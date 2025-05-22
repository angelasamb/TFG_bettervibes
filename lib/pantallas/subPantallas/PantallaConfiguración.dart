import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:tfg_bettervibes/widgets/PlantillaSelector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/funcionalidades/SalirCambiarUnidadFamiliar.dart';


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

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user != null) {
      final doc = await firestore.collection('Usuario').doc(user.uid).get();
      final datos = doc.data();

      if (datos != null) {
        nombreController.text = datos['nombre'] ?? '';
        imagenSeleccionada = datos['fotoPerfil'] ?? '';
        colorSeleccionado = ColorElegido.values.firstWhere(
              (e) => e.name == datos['colorElegido'],
          orElse: () => ColorElegido.Rojo,
        );

        final unidadRef = datos['unidadFamiliarRef'];
        if (unidadRef != null && unidadRef is DocumentReference) {
          unidadFamiliarRef = unidadRef;
          final unidadDoc = await unidadRef.get();

          // Cast seguro a Map<String, dynamic>
          final datosUnidad = unidadDoc.data() as Map<String, dynamic>?;
          unidadFamiliarId = unidadRef.id;
          contraseniaUnidad = datosUnidad?['contrasenia'] ?? '';
        }
        setState(() {});
      }
    }
  }

  Future<void> _guardarCambios() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user != null) {
      await firestore.collection('Usuario').doc(user.uid).update({
        'nombre': nombreController.text.trim(),
        'fotoPerfil': imagenSeleccionada,
        'colorElegido': colorSeleccionado.name,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cambios guardados correctamente")),
      );
    }
  }


  Widget _seccionInvitacion() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Invita a alguien",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("ID Unidad Familiar:"),
            Row(
              children: [
                Expanded(
                  child: SelectableText(unidadFamiliarId),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: unidadFamiliarId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("ID copiado")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text("Contraseña: ${mostrarContrasenia ? contraseniaUnidad : '********'}"),
                IconButton(
                  icon: Icon(
                    mostrarContrasenia ? Icons.visibility : Icons.visibility_off,
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

  Widget _seccionModificarPerfil() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Modificar perfil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Nombre"),
            TextField(controller: nombreController),
            const SizedBox(height: 10),
            Text("Selecciona una imagen"),
            PlantillaSelector(
              esIcono: true,
              itemSeleccionado: imagenSeleccionada,
              onSelect: (dynamic value) {
                setState(() {
                  imagenSeleccionada = value as String;
                });
              },
            ),
            PlantillaSelector(
              esIcono: false, // false para colores
              itemSeleccionado: colorSeleccionado,
              onSelect: (dynamic value) {
                setState(() {
                  colorSeleccionado = value as ColorElegido;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: Text("Guardar cambios"),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
        ),
        onPressed: () async {
          final confirmar = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Confirmar"),
              content: Text(
                  "¿Seguro que quieres salir de la unidad familiar? Esta acción no se puede deshacer."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancelar")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Salir")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _seccionModificarPerfil(),
            _seccionInvitacion(),
            _seccionSalirUnidadFamiliar(),
          ],
        ),
      ),
    );
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
}
