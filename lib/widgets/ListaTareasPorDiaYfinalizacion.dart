import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/clases/Tareas.dart';
import 'package:tfg_bettervibes/clases/TipoTareas.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListaTareasPorDiaYFinalizacion extends StatefulWidget {
  final DateTime fecha;
  final bool mostrarRealizadas;

  const ListaTareasPorDiaYFinalizacion({
    super.key,
    required this.fecha,
    required this.mostrarRealizadas,
  });

  @override
  State<ListaTareasPorDiaYFinalizacion> createState() => _ListaTareasPorDiaYFinalizacionState();
}

class _ListaTareasPorDiaYFinalizacionState extends State<ListaTareasPorDiaYFinalizacion> {
  List<Map<String, dynamic>> tareasConTipo = [];
  bool cargando = true;
  String? error;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _cargarTareasDelDia();
  }

  @override
  void didUpdateWidget(covariant ListaTareasPorDiaYFinalizacion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fecha != widget.fecha || oldWidget.mostrarRealizadas != widget.mostrarRealizadas) {
      _cargarTareasDelDia();
    }
  }

  Future<void> _cargarTareasDelDia() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
      if (unidadFamiliarRef == null) throw "Unidad familiar no encontrada";

      final inicio = DateTime(widget.fecha.year, widget.fecha.month, widget.fecha.day);
      final fin = inicio.add(const Duration(days: 1));

      final querySnapshot = await unidadFamiliarRef
          .collection('Tareas')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('timestamp', isLessThan: Timestamp.fromDate(fin))
          .where('realizada', isEqualTo: widget.mostrarRealizadas)
          .get();

      final tareasDocs = querySnapshot.docs;

      // Obtén referencias únicas de tipoTarea y usuario para hacer menos lecturas
      final tipoTareaRefs = tareasDocs
          .map((doc) => Tareas.fromFirestore2(doc.data()).tipoTareaRef)
          .whereType<DocumentReference>()
          .toSet()
          .toList();

      final usuarioRefs = tareasDocs
          .map((doc) => Tareas.fromFirestore2(doc.data()).usuarioRef)
          .whereType<DocumentReference>()
          .toSet()
          .toList();

      // Obtén datos de tipos de tarea
      final tiposSnapshots = await Future.wait(tipoTareaRefs.map((ref) => ref.get()));
      final tiposMap = <String, TipoTareas>{};
      for (var snap in tiposSnapshots) {
        if (snap.exists) {
          tiposMap[snap.id] = TipoTareas.fromFirestore(snap.data() as Map<String, dynamic>);
        }
      }

      // Obtén colores de usuarios
      final usuariosSnapshots = await Future.wait(usuarioRefs.map((ref) => ref.get()));
      final coloresUsuarios = <String, Color>{};
      for (var snap in usuariosSnapshots) {
        if (snap.exists) {
          coloresUsuarios[snap.id] = getColorFromEnum(snap.get("colorElegido"));
        }
      }

      final List<Map<String, dynamic>> resultado = [];

      for (var doc in tareasDocs) {
        try {
          final tarea = Tareas.fromFirestore2(doc.data());

        if (tarea.tipoTareaRef == null) {
          print("Documento ${doc.id} ERROR: tipoTareaRef es null");
          continue; // Ignorar documento problemático
        }

        if (tarea.usuarioRef == null) {
          print("Documento ${doc.id} ERROR: usuarioRef es null");
          continue; // Ignorar documento problemático
        }

        final tipo = tiposMap[tarea.tipoTareaRef!.id];
        final color = coloresUsuarios[tarea.usuarioRef!.id];

        if (tipo == null) {
          print("Documento ${doc.id} ERROR: tipo no encontrado en tiposMap");
          continue;
        }

        if (color == null) {
          print("Documento ${doc.id} ERROR: color usuario no encontrado");
          continue;
        }

        resultado.add({
          'docRef': doc.reference,
          'tarea': tarea,
          'tipo': tipo,
          'usuarioId': tarea.usuarioRef!.id,
          'color': color,
        });
        } catch (e) {
          print("Error procesando doc ${doc.id}: $e");
        }
      }


      resultado.sort((a, b) {
        final t1 = a['tarea'] as Tareas;
        final t2 = b['tarea'] as Tareas;
        return t1.timestamp.compareTo(t2.timestamp);
      });

      if (mounted) {
        setState(() {
          tareasConTipo = resultado;
          cargando = false;
        });
      }
    } catch (e, stackTrace) {
      print("Error cargando tareas: $e");
      print(stackTrace);
      if (mounted) {
        setState(() {
          error = "Error al cargar tareas: $e";
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));
    if (tareasConTipo.isEmpty) {
      return const Center(
        child: Text("No se encontraron tareas para mostrar"),
      );
    }

    return ListView.builder(
      itemCount: tareasConTipo.length,
      itemBuilder: (context, index) {
        final tarea = tareasConTipo[index]['tarea'] as Tareas;
        final tipo = tareasConTipo[index]['tipo'] as TipoTareas;
        final usuarioId = tareasConTipo[index]['usuarioId'] as String;
        final color = tareasConTipo[index]['color'] as Color;
        final hora = tarea.timestamp.toDate();
        final docRef = tareasConTipo[index]['docRef'] as DocumentReference;

        final horaFormateada =
            "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16),
              elevation: 3,
            ),
            onPressed: () {
              if (userId == usuarioId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaCrearEvento(tareaEditar: docRef),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tipo.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          horaFormateada,
                          style: TextStyle(fontSize: 18, color: color),
                        ),
                        if (!widget.mostrarRealizadas)
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirmar"),
                                  content: const Text("¿Quieres marcar esta tarea como completada?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text("Sí"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmar == true) {
                                await docRef.update({"realizada": true});
                                // Recarga las tareas tras actualizar
                                if (mounted) _cargarTareasDelDia();
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                if (tarea.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    tarea.descripcion,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
