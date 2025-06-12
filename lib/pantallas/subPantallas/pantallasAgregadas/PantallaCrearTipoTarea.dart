import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/widgets/Personalizacion.dart';

import '../../../funcionalidades/FuncionesTipoTareas.dart';
import '../../../widgets/ContadorNumerico.dart';

class PantallaCrearTipoTarea extends StatefulWidget {
  const PantallaCrearTipoTarea({super.key});

  @override
  State<PantallaCrearTipoTarea> createState() => _PantallaCrearTipoTareaState();
}

class _PantallaCrearTipoTareaState extends State<PantallaCrearTipoTarea> {
  DocumentReference? _tipoTareaEditando;

  void _cargarParaEditar(DocumentSnapshot doc) {
    setState(() {
      _tipoTareaEditando = doc.reference;
    });
  }

  void _limpiarCampos() {
    setState(() {
      _tipoTareaEditando = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear/Editar Tipo de Tarea"),
        foregroundColor: Colors.gamaColores.shade500,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TipoTareaForm(
                  tipoTareaEditando: _tipoTareaEditando,
                  onCancelar: _limpiarCampos,
                  onGuardado: _limpiarCampos,
                ),
                const SizedBox(height: 20),
                Expanded(child: ListaTiposTareas(onEditar: _cargarParaEditar)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TipoTareaForm extends StatefulWidget {
  final DocumentReference? tipoTareaEditando;
  final VoidCallback onCancelar;
  final VoidCallback onGuardado;

  const TipoTareaForm({
    Key? key,
    required this.tipoTareaEditando,
    required this.onCancelar,
    required this.onGuardado,
  }) : super(key: key);

  @override
  _TipoTareaFormState createState() => _TipoTareaFormState();
}

class _TipoTareaFormState extends State<TipoTareaForm> {
  final TextEditingController _nombreCtrl = TextEditingController();
  int _puntuacionSeleccionada = 0;

  @override
  void didUpdateWidget(covariant TipoTareaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tipoTareaEditando != oldWidget.tipoTareaEditando) {
      if (widget.tipoTareaEditando != null) {
        widget.tipoTareaEditando!.get().then((doc) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nombreCtrl.text = data['nombre'] ?? '';
            _puntuacionSeleccionada = data['puntuacion'] ?? 0;
          });
        });
      } else {
        setState(() {
          _nombreCtrl.clear();
          _puntuacionSeleccionada = 0;
        });
      }
    }
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Completa el nombre")));
      return;
    }

    if (widget.tipoTareaEditando != null) {
      await editarTipoTarea(
        widget.tipoTareaEditando!,
        nombre,
        _puntuacionSeleccionada,
      );
    } else {
      await crearTipoTarea(nombre, _puntuacionSeleccionada);
    }

    widget.onGuardado();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.tipoTareaEditando != null;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            plantillaField(_nombreCtrl, "Nombre del tipo de tarea"),
            const SizedBox(height: 20),
            ContadorNumerico(
              valor: _puntuacionSeleccionada,
              onChanged: (val) => setState(() => _puntuacionSeleccionada = val),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _guardar,
                  child: Text(editando ? "Guardar cambios" : "Crear"),
                ),
                if (editando) ...[
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: widget.onCancelar,
                    child: const Text("Cancelar"),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ListaTiposTareas extends StatelessWidget {
  final Function(DocumentSnapshot) onEditar;

  const ListaTiposTareas({Key? key, required this.onEditar}) : super(key: key);

  Future<void> _borrarTipoTarea(
    BuildContext context,
    DocumentReference ref,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmar borrado"),
            content: const Text(
              "¿Seguro que quieres borrar este tipo de tarea?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Borrar"),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await borrarTipoTarea(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: obtenerTiposTareasStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text("No hay tipos de tareas creados"));

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
                onPressed: () => _borrarTipoTarea(context, doc.reference),
              ),
              onTap: () => onEditar(doc),
            );
          },
        );
      },
    );
  }
}
