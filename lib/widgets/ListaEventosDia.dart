import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tfg_bettervibes/clases/Eventos.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfg_bettervibes/clases/ColorElegido.dart';

class ListaEventosDia extends StatefulWidget {
  final DateTime fecha;

  const ListaEventosDia({super.key, required this.fecha});

  @override
  State<ListaEventosDia> createState() => _ListaEventosDiaState();
}

class _ListaEventosDiaState extends State<ListaEventosDia> {
  List<Map<String, dynamic>> eventosConColor = [];
  bool cargando = true;
  String? error;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _cargarEventosDelDia();
  }

  Future<void> _cargarEventosDelDia() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
      if (unidadFamiliarRef == null) throw "Unidad familiar no encontrada";

      final inicio = DateTime(
        widget.fecha.year,
        widget.fecha.month,
        widget.fecha.day,
      );
      final fin = inicio.add(const Duration(days: 7));

      final querySnapshot =
          await unidadFamiliarRef
              .collection('Eventos')
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
              )
              .where('timestamp', isLessThan: Timestamp.fromDate(fin))
              .get();

      final eventosDocs =
          querySnapshot.docs
              .map(
                (doc) => Eventos.fromFirestore2(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .where(
                (evento) =>
                    evento.usuarioRef == null ||
                    evento.usuarioRef!.id == userId,
              )
              .toList();

      // Obtener colores de usuarios
      final usuarioRefs =
          eventosDocs
              .map((evento) => evento.usuarioRef)
              .whereType<DocumentReference>()
              .toSet()
              .toList();

      final usuariosSnapshots = await Future.wait(
        usuarioRefs.map((ref) => ref.get()),
      );
      final coloresUsuarios = <String, Color>{};

      for (var snap in usuariosSnapshots) {
        if (snap.exists) {
          coloresUsuarios[snap.id] = getColorFromEnum(snap.get("colorElegido"));
        }
      }

      final List<Map<String, dynamic>> resultado = [];

      for (var evento in eventosDocs) {
        final color =
            evento.usuarioRef == null
                ? Colors.black
                : coloresUsuarios[evento.usuarioRef!.id] ?? Colors.black;

        resultado.add({'evento': evento, 'color': color});
      }

      resultado.sort(
        (a, b) => (a['evento'] as Eventos).timestamp.compareTo(
          (b['evento'] as Eventos).timestamp,
        ),
      );

      if (mounted) {
        setState(() {
          eventosConColor = resultado;
          cargando = false;
        });
      }
    } catch (e, stackTrace) {
      print("Error cargando eventos: $e");
      print(stackTrace);
      if (mounted) {
        setState(() {
          error = "Error al cargar eventos: $e";
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));
    if (eventosConColor.isEmpty)
      return const Center(child: Text("No hay eventos para mostrar"));

    return ListView.builder(
      itemCount: eventosConColor.length,
      itemBuilder: (context, index) {
        final evento = eventosConColor[index]['evento'] as Eventos;
        final color = eventosConColor[index]['color'] as Color;
        final fecha = evento.timestamp.toDate();
        final horaFormateada =
            "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
        final fechaFormateada = DateFormat("EEEE, dd MMM").format(fecha);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fechaFormateada),
              ListTile(
                title: Text(
                  evento.nombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                subtitle:
                    evento.descripcion != null
                        ? Text(
                          evento.descripcion!,
                          style: TextStyle(color: Colors.grey.shade700),
                        )
                        : null,
                trailing: Text(
                  horaFormateada,
                  style: TextStyle(fontSize: 18, color: color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
