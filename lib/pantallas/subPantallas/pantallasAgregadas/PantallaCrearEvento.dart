import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../funcionalidades/FuncionesEventos.dart';
import '../../../widgets/personalizacion.dart';

class PantallaCrearEvento extends StatefulWidget {
  final DateTime fechaSeleccionada;

  const PantallaCrearEvento({super.key, required this.fechaSeleccionada});

  @override
  State<PantallaCrearEvento> createState() => _PantallaCrearEventoState();
}

class _PantallaCrearEventoState extends State<PantallaCrearEvento> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  TimeOfDay? _horaSeleccionada;
  bool _paraTodos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Crear Evento'),
        backgroundColor: Colors.gamaColores.shade100,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            plantillaField(_nombreCtrl, 'Nombre del evento'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _descripcionCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Descripción',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
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
            Row(
              children: [
                const Text('Hora: '),
                Text(
                  _horaSeleccionada != null
                      ? _horaSeleccionada!.format(context)
                      : 'No seleccionada',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.gamaColores.shade100,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (hora != null) {
                      setState(() {
                        _horaSeleccionada = hora;
                      });
                    }
                  },
                  child: const Text('Elegir hora'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Evento para toda la familia"),
              activeColor: Colors.gamaColores.shade100,
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
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.gamaColores.shade100,
                    side: BorderSide(color: Colors.gamaColores.shade100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.gamaColores.shade100,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final nombre = _nombreCtrl.text.trim();
                    final descripcion = _descripcionCtrl.text.trim();

                    if (_horaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Por favor, selecciona la hora del evento"),
                        ),
                      );
                      return;
                    }

                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Por favor, completa el nombre del evento"),
                        ),
                      );
                      return;
                    }

                    final fecha = DateTime(
                      widget.fechaSeleccionada.year,
                      widget.fechaSeleccionada.month,
                      widget.fechaSeleccionada.day,
                      _horaSeleccionada!.hour,
                      _horaSeleccionada!.minute,
                    );

                    await crearEventoEnUnidadFamiliar(
                      context: context,
                      nombre: nombre,
                      descripcion: descripcion.isEmpty ? null : descripcion,
                      timestamp: Timestamp.fromDate(fecha),
                      usuarioRefEvento: _paraTodos
                          ? null
                          : FirebaseFirestore.instance.collection('Usuario').doc(FirebaseAuth.instance.currentUser!.uid),
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
