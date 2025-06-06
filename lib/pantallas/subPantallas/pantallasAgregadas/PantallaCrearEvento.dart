import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesTareas.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesUsuario.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';

import '../../../funcionalidades/FuncionesEventos.dart';
import '../../../widgets/personalizacion.dart';

class PantallaCrearEvento extends StatefulWidget {
  final String tipoActividad;
  final DocumentReference? tareaEditar;
  final DocumentReference? eventoEditar;
  final DateTime? fechaSeleccionada;

  const PantallaCrearEvento({
    super.key,
    this.tipoActividad = "evento",
    this.eventoEditar,
    this.tareaEditar,
    this.fechaSeleccionada,
  });

  @override
  State<PantallaCrearEvento> createState() => _PantallaCrearEventoState();
}

class _PantallaCrearEventoState extends State<PantallaCrearEvento> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  late String _tipoActividad = widget.tipoActividad;
  TimeOfDay? _horaSeleccionada;
  bool _paraTodos = false;
  late DateTime _fechaSeleccionada;
  List<Map<String, dynamic>> listaTipoTareas = [];
  String? tipoTareaSeleccionada;
  late DocumentReference _tipoTareaRef;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.fechaSeleccionada ?? DateTime.now();
    cargaDatos();
  }

  Future<void> cargaDatos() async {
    await cogerTipoTareas();

    if (widget.tareaEditar != null) {
      _tipoActividad = "tarea";

      await cargarDatosTarea();
    } else if (widget.eventoEditar != null) {
      _tipoActividad = "evento";
      await cargarDatosEvento();
    } else {
      _tipoActividad = widget.tipoActividad;
    }

  }

  @override
  Widget build(BuildContext context) {
    if (_tipoActividad.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tipoActividad == "evento" ? "Crear evento" : "Crear tarea",
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.gamaColores.shade500,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                if (widget.tareaEditar == null)
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Evento"),
                      value: "evento",
                      groupValue: _tipoActividad,
                      activeColor: Colors.gamaColores.shade100,
                      onChanged: (value) {
                        setState(() {
                          _tipoActividad = value!;
                        });
                      },
                    ),
                  ),
                if (widget.eventoEditar == null)
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Tarea"),
                      value: "tarea",
                      groupValue: _tipoActividad,
                      activeColor: Colors.gamaColores.shade100,
                      onChanged: (value) {
                        setState(() {
                          _tipoActividad = value!;
                          //TODO: MOSTRAR EL NOMBRE LA TAREA AL EDITARLO
                        });
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_tipoActividad == "evento")
              plantillaField(_nombreCtrl, "Nombre del evento"),
            if (_tipoActividad == "tarea")
              DropdownButton(
                value: tipoTareaSeleccionada,
                hint: Text("Escoge un tipo de tarea"),
                items:
                    listaTipoTareas.map((mapa) {
                      return DropdownMenuItem<String>(
                        value: mapa["nombre"],
                        child: Text(mapa["nombre"]),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    tipoTareaSeleccionada = value as String;
                    _tipoTareaRef =
                        listaTipoTareas.firstWhere(
                          (mapa) => mapa["nombre"] == value,
                        )["ref"];
                  });
                },
              ),
            const SizedBox(height: 20),
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
                  '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.gamaColores.shade200,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final nuevaFecha = await showDatePicker(
                      context: context,
                      initialDate: _fechaSeleccionada,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2040),
                    );
                    if (nuevaFecha != null) {
                      setState(() {
                        _fechaSeleccionada = nuevaFecha;
                      });
                    }
                  },
                  child: const Text("Cambiar fecha"),
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
                    backgroundColor: Colors.gamaColores.shade200,
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
            if (_tipoActividad == "evento")
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
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.gamaColores.shade500,
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
                        SnackBar(
                          content: Text(
                            _tipoActividad == "evento"
                                ? "Por favor, selecciona la hora del evento"
                                : "Por favor, selecciona la hora de la tarea",
                          ),
                        ),
                      );
                      return;
                    }

                    if (_tipoActividad == "evento" && nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Por favor, completa el nombre del evento",
                          ),
                        ),
                      );
                      return;
                    }
                    if (_tipoActividad == "tarea" &&
                        tipoTareaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Por favor, completa el nombre del evento",
                          ),
                        ),
                      );
                      return;
                    }

                    final fecha = DateTime(
                      _fechaSeleccionada.year,
                      _fechaSeleccionada.month,
                      _fechaSeleccionada.day,
                      _horaSeleccionada!.hour,
                      _horaSeleccionada!.minute,
                    );

                    if (_tipoActividad == "evento") {
                      if (widget.eventoEditar != null) {
                        final usuarioRef =
                            _paraTodos
                                ? null
                                : FirebaseFirestore.instance
                                    .collection("Usuario")
                                    .doc(
                                      FirebaseAuth.instance.currentUser!.uid,
                                    );

                        await editarEventoEnUnidadFamiliar(
                          context: context,
                          eventoEditar: widget.eventoEditar,
                          nombre: nombre,
                          timestamp: Timestamp.fromDate(fecha),
                          usuarioRefEvento: usuarioRef,
                        );
                      } else {
                        await crearEventoEnUnidadFamiliar(
                          context: context,
                          nombre: nombre,
                          descripcion: descripcion.isEmpty ? "" : descripcion,
                          timestamp: Timestamp.fromDate(fecha),
                          usuarioRefEvento:
                              _paraTodos
                                  ? null
                                  : FirebaseFirestore.instance
                                      .collection('Usuario')
                                      .doc(
                                        FirebaseAuth.instance.currentUser!.uid,
                                      ),
                        );
                      }
                    } else if (_tipoActividad == "tarea") {
                      if (widget.tareaEditar != null) {
                        await editarTareaEnUnidadFamiliar(
                          context,
                          widget.tareaEditar,
                          fecha,
                          descripcion,
                          _tipoTareaRef,
                        );
                      } else {
                        await crearTareaEnUnidadFamiliar(
                          context: context,
                          realizada: false,
                          timestamp: Timestamp.fromDate(fecha),
                          tipoTareaRef: _tipoTareaRef,
                          descripcion: descripcion,
                        );
                      }
                    }

                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),

                if (widget.tareaEditar != null || widget.eventoEditar != null)
                  const SizedBox(width: 60),
                if (widget.tareaEditar != null || widget.eventoEditar != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final doc = widget.eventoEditar ?? widget.tareaEditar;
                      final confirmar = await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text("Confirmar"),
                              content: Text("¿Quieres borrar este elemento?"),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text("Sí"),
                                ),
                              ],
                            ),
                      );
                      if (doc != null && confirmar) {
                        borrarDocEnUnidadFamiliar(doc: doc, context: context);
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Borrar"),
                  ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> cogerTipoTareas() async {
    final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
    final snapshot = await unidadFamiliarRef!.collection("TipoTareas").get();
    final nombres =
        snapshot.docs.map(
          (doc) {
            return {"nombre": doc["nombre"] as String, "ref": doc.reference};
          },
        ).toList(); //obtiene lista de documentos, recorre cada documento y accede al "nombre" de cada uno y convierte el resultado en List<String>
    setState(() {
      listaTipoTareas = nombres;
    });
  }

  Future<void> cargarDatosTarea() async {
    final doc = await widget.tareaEditar!.get();
    final datos = doc.data() as Map<String, dynamic>;
    setState(() {
      _tipoActividad = "tarea";
      _nombreCtrl.text = datos["nombre"] ?? "";
      _descripcionCtrl.text = datos["descripcion"] ?? "";
      _horaSeleccionada = TimeOfDay.fromDateTime(
        (datos["timestamp"] as Timestamp).toDate(),
      );
      _fechaSeleccionada = (datos["timestamp"] as Timestamp).toDate();
      _tipoTareaRef = datos["tipotareaRef"] as DocumentReference;
      tipoTareaSeleccionada =
          listaTipoTareas.firstWhere(
                (mapa) => mapa["ref"].id == _tipoTareaRef.id,
                orElse: () => <String, Object>{"nombre": "Sin nombre"},
              )["nombre"]
              as String;
    });
  }
  Future<void> cargarDatosEvento() async {
    print(widget.eventoEditar);
    final doc = await widget.eventoEditar!.get();
    if (doc.exists) { // Add this check
      final datos = doc.data() as Map<String, dynamic>;
      setState(() {
        _tipoActividad = "evento";
        _nombreCtrl.text = datos["nombre"] ?? "";
        _descripcionCtrl.text = datos["descripcion"] ?? "";
        _horaSeleccionada = TimeOfDay.fromDateTime(
          (datos["timestamp"] as Timestamp).toDate(),
        );
        _fechaSeleccionada = (datos["timestamp"] as Timestamp).toDate();
        _paraTodos = datos["usuarioRefEvento"] == null;
      });
    } else {
      // Handle the case where the document doesn't exist
      // You could show a message to the user,
      // navigate back, or set default values.
      print("Error: El evento no existe en Firestore.");
      // Optionally, navigate back or show an error message
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("El evento que intentas editar no existe.")),
      // );
    }
  }
}
