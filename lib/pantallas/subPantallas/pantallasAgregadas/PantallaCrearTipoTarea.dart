import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../funcionalidades/FuncionesTipoTareas.dart';
import '../../../widgets/ContadorNumerico.dart';

class PantallaCrearTipoTarea extends StatefulWidget {
  const PantallaCrearTipoTarea({super.key});

  @override
  State<PantallaCrearTipoTarea> createState() => _PantallaCrearTipoTareaState();
}

class _PantallaCrearTipoTareaState extends State<PantallaCrearTipoTarea> {
  final TextEditingController _nombreCtrl = TextEditingController();
  int _puntuacionSeleccionada = 0;
  DocumentReference? _tipoTareaEditando;

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    final puntuacion = _puntuacionSeleccionada;

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Completa el nombre")));
      return;
    }

    if (_tipoTareaEditando != null) {
      await editarTipoTarea(_tipoTareaEditando!, nombre, puntuacion);
    } else {
      await crearTipoTarea(nombre, puntuacion);
    }
    _limpiarCampos();
  }

  void _limpiarCampos() {
    setState(() {
      _tipoTareaEditando = null;
      _nombreCtrl.clear();
      _puntuacionSeleccionada = 0;
    });
  }

  void _cargarParaEditar(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _tipoTareaEditando = doc.reference;
      _nombreCtrl.text = data["nombre"] ?? "";
      _puntuacionSeleccionada = data["puntuacion"] ?? 0;
    });
  }

  Future<void> _borrarTipoTarea(DocumentReference ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar borrado"),
        content: const Text("¿Seguro que quieres borrar este tipo de tarea?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Borrar")),
        ],
      ),
    );

    if (confirmar == true) {
      await borrarTipoTarea(ref);
      if (_tipoTareaEditando == ref) _limpiarCampos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear/Editar Tipo de Tarea"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre del tipo de tarea",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Puntuación: "),
                ContadorNumerico(
                  valor: _puntuacionSeleccionada,
                  min: 0,
                  max: 99,
                  onChanged: (val) {
                    setState(() {
                      _puntuacionSeleccionada = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardar,
              child: Text(_tipoTareaEditando == null ? "Crear" : "Guardar cambios"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: obtenerTiposTareasStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) return const Text("No hay tipos de tareas creados");

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data["nombre"] ?? ""),
                        subtitle: Text("Puntos: ${data["puntuacion"] ?? 0}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _borrarTipoTarea(doc.reference),
                        ),
                        onTap: () => _cargarParaEditar(doc),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
