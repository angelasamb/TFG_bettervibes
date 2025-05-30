import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../funcionalidades/FuncionesEventos.dart';

class PantallaCrearEvento extends StatefulWidget {
  final DateTime fechaSeleccionada;

  const PantallaCrearEvento({super.key, required this.fechaSeleccionada});

  @override
  State<PantallaCrearEvento> createState() => _PantallaCrearEventoState();
}

class _PantallaCrearEventoState extends State<PantallaCrearEvento> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  bool _paraTodos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del evento',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Fecha: '),
                Text(
                  '${widget.fechaSeleccionada.day}/${widget.fechaSeleccionada.month}/${widget.fechaSeleccionada.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Evento para toda la familia"),
              value: _paraTodos,
              onChanged: (value) {
                setState(() {
                  _paraTodos = value ?? false;
                });
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nombre = _nombreCtrl.text.trim();
                    final descripcion = _descripcionCtrl.text.trim();
                    final fecha = widget.fechaSeleccionada;

                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Por favor, completa el nombre del evento")),
                      );
                      return;
                    }

                    await crearEventoEnUnidadFamiliar(
                      context: context,
                      nombre: nombre,
                      descripcion: descripcion.isEmpty ? null : descripcion,
                      timestamp: Timestamp.fromDate(fecha),
                      usuarioRef: _paraTodos ? null : FirebaseFirestore.instance.collection('Usuario').doc(FirebaseAuth.instance.currentUser!.uid),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
