
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../clases/Eventos.dart';

class ListaEventosPorDia extends StatefulWidget {
  final DateTime fecha;

  const ListaEventosPorDia({super.key, required this.fecha});

  @override
  State<ListaEventosPorDia> createState() => _ListaEventosPorDiaState();
}

class _ListaEventosPorDiaState extends State<ListaEventosPorDia> {
  List<Eventos> eventosFiltrados = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarEventosDelDia();
  }

  @override
  void didUpdateWidget(covariant ListaEventosPorDia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.fecha, widget.fecha)) {
      _cargarEventosDelDia();
    }
  }

  Future<void> _cargarEventosDelDia() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          error = "Usuario no autenticado";
          cargando = false;
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final usuarioRef = firestore.collection('Usuario').doc(user.uid);
      final docUsuario = await usuarioRef.get();

      if (!docUsuario.exists) {
        setState(() {
          error = "Documento de usuario no encontrado";
          cargando = false;
        });
        return;
      }

      final dataUsuario = docUsuario.data()!;
      if (!dataUsuario.containsKey('unidadFamiliarRef')) {
        setState(() {
          error = "Unidad familiar no encontrada en usuario";
          cargando = false;
        });
        return;
      }

      final unidadFamiliarRef = dataUsuario['unidadFamiliarRef'] as DocumentReference;
      final docUnidad = await unidadFamiliarRef.get();

      if (!docUnidad.exists) {
        setState(() {
          error = "Unidad familiar no encontrada";
          cargando = false;
        });
        return;
      }

      final dataUnidad = docUnidad.data() as Map<String, dynamic>;
      final List<dynamic> eventos = dataUnidad['eventos'] ?? [];

      final dia = widget.fecha;
      final diaInicio = DateTime(dia.year, dia.month, dia.day);
      final diaFin = diaInicio.add(const Duration(days: 1));

      final eventosFiltradosDia = eventos.where((eventoMap) {
        if (eventoMap is! Map<String, dynamic>) return false;

        // Aquí manejo el fromFirestore con campos opcionales nulos seguros
        try {
          // Mapeo seguro de campos, porque pueden no estar o ser null
          final descripcion = eventoMap["descripcion"] as String?;
          final nombre = eventoMap["nombre"] as String?;
          final timestamp = eventoMap["timestamp"] as Timestamp?;
          final usuarioRef = eventoMap["usuarioRef"] as DocumentReference?;

          if (nombre == null || timestamp == null) return false;

          final evento = Eventos(
            descripcion: descripcion,
            nombre: nombre,
            timestamp: timestamp,
            usuarioRef: usuarioRef,
          );

          final fechaEvento = evento.timestamp.toDate();

          if (fechaEvento.isBefore(diaInicio) || !fechaEvento.isBefore(diaFin)) return false;

          // Filtrar solo eventos sin usuarioRef o que coincidan con el usuario actual
          return evento.usuarioRef == null || evento.usuarioRef!.id == user.uid;
        } catch (_) {
          return false;
        }
      }).map((eventoMap) {
        final descripcion = (eventoMap as Map<String, dynamic>)["descripcion"] as String?;
        final nombre = eventoMap["nombre"] as String;
        final timestamp = eventoMap["timestamp"] as Timestamp;
        final usuarioRef = eventoMap["usuarioRef"] as DocumentReference?;

        return Eventos(
          descripcion: descripcion,
          nombre: nombre,
          timestamp: timestamp,
          usuarioRef: usuarioRef,
        );
      }).toList();

      setState(() {
        eventosFiltrados = eventosFiltradosDia;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = "Error cargando eventos: $e";
        cargando = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));
    if (eventosFiltrados.isEmpty) return const Center(child: Text("No hay eventos para este día"));

    return ListView.builder(
      itemCount: eventosFiltrados.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final evento = eventosFiltrados[index];
        final nombre = evento.nombre;
        final descripcion = evento.descripcion ?? '';
        final fechaHora = evento.timestamp.toDate();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(nombre),
            subtitle: descripcion.isNotEmpty ? Text(descripcion) : null,
            trailing: Text(
              "${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Navegación a pantalla de detalle
              print('Tocar evento: $nombre');
              // Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaDetalleEvento(evento: evento)));
            },
          ),
        );
      },
    );
  }
}