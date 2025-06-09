import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../funcionalidades/FuncionesPagos.dart';

class SelectorUsuarioPagador extends StatefulWidget {
  final DocumentReference? pagadorSeleccionado;
  final ValueChanged<DocumentReference?> onUsuarioSeleccionado;
  final DocumentReference unidadFamiliarRef;

  const SelectorUsuarioPagador({
    super.key,
    required this.pagadorSeleccionado,
    required this.onUsuarioSeleccionado,
    required this.unidadFamiliarRef,
  });

  @override
  State<SelectorUsuarioPagador> createState() => _SelectorUsuarioPagadorState();
}

class _SelectorUsuarioPagadorState extends State<SelectorUsuarioPagador> {
  List<DocumentSnapshot> _usuarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final usuarios = await FuncionesPagos.obtenerUsuariosParticipantes(widget.unidadFamiliarRef);
    setState(() {
      _usuarios = usuarios;
      _cargando = false;
    });
  }

  void _mostrarSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        if (_cargando) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: _usuarios.length,
          itemBuilder: (_, i) {
            final usuario = _usuarios[i];
            final nombre = (usuario.data() as Map<String, dynamic>?)?['nombre'] ?? 'Sin nombre';
            final seleccionado = usuario.reference == widget.pagadorSeleccionado;
            return ListTile(
              title: Text(nombre),
              trailing: seleccionado ? const Icon(Icons.check) : null,
              onTap: () {
                widget.onUsuarioSeleccionado(usuario.reference);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String textoMostrar = "Selecciona pagador";
    if (widget.pagadorSeleccionado != null) {
      final usuario = _usuarios.firstWhere(
            (u) => u.reference == widget.pagadorSeleccionado,
        orElse: () => _usuarios.first,
      );
      if (usuario != null) {
        textoMostrar = (usuario.data() as Map<String, dynamic>?)?['nombre'] ?? textoMostrar;
      }
    }

    return ListTile(
      title: Text(textoMostrar),
      leading: const Icon(Icons.person),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: _mostrarSelector,
    );
  }
}

class SelectorUsuariosParticipantes extends StatefulWidget {
  final List<DocumentReference> participantesSeleccionados;
  final ValueChanged<List<DocumentReference>> onSeleccionCambiada;
  final DocumentReference unidadFamiliarRef;

  const SelectorUsuariosParticipantes({
    super.key,
    required this.participantesSeleccionados,
    required this.onSeleccionCambiada,
    required this.unidadFamiliarRef,
  });

  @override
  State<SelectorUsuariosParticipantes> createState() => _SelectorUsuariosParticipantesState();
}

class _SelectorUsuariosParticipantesState extends State<SelectorUsuariosParticipantes> {
  List<DocumentSnapshot> _usuarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final usuarios = await FuncionesPagos.obtenerUsuariosParticipantes(widget.unidadFamiliarRef);
    setState(() {
      _usuarios = usuarios;
      _cargando = false;
    });
  }

  void _mostrarSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        if (_cargando) return const Center(child: CircularProgressIndicator());

        List<DocumentReference> seleccionados = List.from(widget.participantesSeleccionados);

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _usuarios.length,
                    itemBuilder: (_, i) {
                      final usuario = _usuarios[i];
                      final nombre = (usuario.data() as Map<String, dynamic>?)?['nombre'] ?? 'Sin nombre';
                      final estaSeleccionado = seleccionados.contains(usuario.reference);
                      return CheckboxListTile(
                        title: Text(nombre),
                        value: estaSeleccionado,
                        onChanged: (valor) {
                          setStateModal(() {
                            if (valor == true) {
                              seleccionados.add(usuario.reference);
                            } else {
                              seleccionados.remove(usuario.reference);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    widget.onSeleccionCambiada(seleccionados);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${widget.participantesSeleccionados.length} participantes seleccionados'),
      leading: const Icon(Icons.group),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: _mostrarSelector,
    );
  }
}
