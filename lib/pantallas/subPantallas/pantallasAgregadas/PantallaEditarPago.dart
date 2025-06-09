import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../funcionalidades/FuncionesPagos.dart';
import '../../../funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/widgets/ListaUsuarios.dart';

class PantallaEditarPago extends StatefulWidget {
  final String? idPago;

  const PantallaEditarPago({super.key, this.idPago});

  @override
  State<PantallaEditarPago> createState() => _PantallaEditarPagoState();
}

class _PantallaEditarPagoState extends State<PantallaEditarPago> {
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();
  DocumentReference? _pagador;
  List<DocumentReference> _participantes = [];
  DocumentReference? _unidadFamiliarRef;

  bool _cargandoDatos = true;

  bool get esEdicion => widget.idPago != null && widget.idPago!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final unidadRef = await obtenerUnidadFamiliarRefActual();
    if (unidadRef == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener unidad familiar')),
        );
        Navigator.pop(context);
      }
      return;
    }
    _unidadFamiliarRef = unidadRef;

    if (esEdicion) {
      final pago = await FuncionesPagos.cargarPago(
        unidadFamiliarRef: unidadRef,
        idPago: widget.idPago!,
      );

      if (pago == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pago no encontrado')),
          );
          Navigator.pop(context);
        }
        return;
      }

      _descripcionController.text = pago.descripcion ?? '';
      _precioController.text = pago.precio.toString();
      _fechaSeleccionada = pago.timestamp.toDate();
      _pagador = pago.pagadorRef;
      _participantes = pago.participantes;
    }

    if (mounted) {
      setState(() {
        _cargandoDatos = false;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (nuevaFecha != null) {
      setState(() => _fechaSeleccionada = nuevaFecha);
    }
  }

  bool _validarCampos() {
    final precio = double.tryParse(_precioController.text);
    if (precio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser un número válido')),
      );
      return false;
    }
    if (_pagador == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un pagador')),
      );
      return false;
    }
    if (_participantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos un participante')),
      );
      return false;
    }
    return true;
  }

  Future<void> _guardarPago() async {
    if (!_validarCampos() || _unidadFamiliarRef == null) return;

    final precio = double.parse(_precioController.text);

    await FuncionesPagos.guardarPago(
      unidadFamiliarRef: _unidadFamiliarRef!,
      idPago: widget.idPago,
      descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      precio: precio,
      fecha: _fechaSeleccionada,
      pagadorRef: _pagador!,
      participantes: _participantes,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _eliminarPago() async {
    if (_unidadFamiliarRef == null || !esEdicion) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar pago?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FuncionesPagos.eliminarPago(
        unidadFamiliarRef: _unidadFamiliarRef!,
        idPago: widget.idPago!,
      );
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _precioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoDatos) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Pago' : 'Nuevo Pago'),
        actions: [
          if (esEdicion)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _eliminarPago,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: "Descripción (opcional)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Precio"),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _seleccionarFecha,
            ),
            const SizedBox(height: 12),
            SelectorUsuarioPagador(
              unidadFamiliarRef: _unidadFamiliarRef!,
              pagadorSeleccionado: _pagador,
              onUsuarioSeleccionado: (nuevoPagador) {
                setState(() {
                  _pagador = nuevoPagador;
                });
              },
            ),
            const SizedBox(height: 12),
            SelectorUsuariosParticipantes(
              unidadFamiliarRef: _unidadFamiliarRef!,
              participantesSeleccionados: _participantes,
              onSeleccionCambiada: (nuevosParticipantes) {
                setState(() {
                  _participantes = nuevosParticipantes;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarPago,
              child: Text(esEdicion ? 'Guardar cambios' : 'Crear pago'),
            ),
          ],
        ),
      ),
    );
  }
}