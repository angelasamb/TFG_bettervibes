import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_bettervibes/funcionalidades/FuncionesTareas.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/funcionalidades/PuntuacionSemanal.dart';

import '../../../funcionalidades/FuncionesEventos.dart';
import '../../../widgets/Personalizacion.dart';

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
  final usuarioRef = FirebaseFirestore.instance
      .collection("Usuario")
      .doc(FirebaseAuth.instance.currentUser!.uid);
  bool _tareaRealizada = false;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.fechaSeleccionada ?? DateTime.now();
    if(widget.tareaEditar==null && widget.eventoEditar==null){
      _horaSeleccionada =TimeOfDay.now();
    }
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
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.all(25),
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
                    hint: Text(
                      "Escoge un tipo de tarea",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
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
                plantillaField(_descripcionCtrl, "Descripción"),

                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    "Fecha: ${DateFormat("dd/MM/yyyy").format(_fechaSeleccionada)}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _seleccionarFecha,
                ),
                const SizedBox(width: 16),
                ListTile(
                  title: Text(
                    "Hora: ${_horaSeleccionada != null ? _horaSeleccionada!.format(context) : "No seleccionada"}",
                  ),
                  trailing: const Icon(Icons.timelapse_outlined),
                  onTap: _seleccionarHora,
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
                if (widget.tareaEditar != null && _tareaRealizada)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.gamaColores.shade200,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: marcarComoNoCompletada,
                    child: Text("Desmarcar como realizada"),

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
                        _guardarDatos();
                      },
                      child: const Text("Guardar"),
                    ),
                    if (widget.tareaEditar != null ||
                        widget.eventoEditar != null)//para que no salga el espacio si esto no ocurre
                    const SizedBox(width: 60),
                    if (widget.tareaEditar != null ||
                        widget.eventoEditar != null)
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
                                  content: Text(
                                    "¿Quieres borrar este elemento?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
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
                            borrarDocEnUnidadFamiliar(
                              doc: doc,
                              context: context,
                            );

                            CalculoPuntuacionSemanal(usuarioRef);
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
      _tareaRealizada = datos["realizada"] ?? false;
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
    final doc = await widget.eventoEditar!.get();
    final datos = doc.data() as Map<String, dynamic>;
    setState(() {
      _tipoActividad = "evento";
      _nombreCtrl.text = datos["nombre"] ?? "";
      _descripcionCtrl.text = datos["descripcion"] ?? "";
      _horaSeleccionada = TimeOfDay.fromDateTime(
        (datos["timestamp"] as Timestamp).toDate(),
      );
      _fechaSeleccionada = (datos["timestamp"] as Timestamp).toDate();
      _paraTodos = datos["usuarioRef"] == null;
    });
  }

  void marcarComoNoCompletada() async {
    widget.tareaEditar?.update({"realizada": false});

    CalculoPuntuacionSemanal(usuarioRef);
    Navigator.pop(context);
  }

  void _guardarDatos() async {
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
        SnackBar(content: Text("Por favor, completa el nombre del evento")),
      );
      return;
    }
    if (_tipoActividad == "tarea" && tipoTareaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, completa el nombre de la tarea")),
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
                    .doc(FirebaseAuth.instance.currentUser!.uid);

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
                      .collection("Usuario")
                      .doc(FirebaseAuth.instance.currentUser!.uid),
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
        CalculoPuntuacionSemanal(usuarioRef);
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
  }

  void _seleccionarFecha() async {
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
  }

  void _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }
}
