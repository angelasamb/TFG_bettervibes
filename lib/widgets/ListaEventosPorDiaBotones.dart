import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';
import '../clases/Eventos.dart';
import '../funcionalidades/MainFunciones.dart';

class ListaEventosPorDiaBotones extends StatefulWidget {
  final DateTime fecha;

  const ListaEventosPorDiaBotones({super.key, required this.fecha});

  @override
  State<ListaEventosPorDiaBotones> createState() => _ListaEventosPorDiaBotonesState();
}

class _ListaEventosPorDiaBotonesState extends State<ListaEventosPorDiaBotones> {
  List<Eventos> eventosFiltrados = [];
  bool cargando = true;
  String? error;
  late DocumentReference? unidadFamiliarRef;
  @override
  void initState() {
    super.initState();
    _cargarEventosDelDia();
  }

  @override
  void didUpdateWidget(covariant ListaEventosPorDiaBotones oldWidget) {
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
        error = "Usuario no autenticado";
        cargando = false;
        setState(() {});
        return;
      }

      unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
      if (unidadFamiliarRef == null) {
        error = "No se encontró la unidad familiar";
        cargando = false;
        setState(() {});
        return;
      }

      final diaInicio = DateTime(widget.fecha.year, widget.fecha.month, widget.fecha.day);
      final diaFin = diaInicio.add(const Duration(days: 1));

      final snapshot = await unidadFamiliarRef
          !.collection("Eventos")
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(diaInicio))
          .where("timestamp", isLessThan: Timestamp.fromDate(diaFin))
          .get();

      final eventos = snapshot.docs.map((doc) {
        return Eventos.fromFirestore(doc);
      }).where((evento) {
        // Filtra por usuario si tiene usuarioRef
        return evento.usuarioRef == null || evento.usuarioRef!.id == user.uid;
      }).toList();

      setState(() {
        eventosFiltrados = eventos;
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
        final fechaHora = evento.timestamp.toDate();
        final descripcion = evento.descripcion ?? '';
        DocumentReference eventoEditar = unidadFamiliarRef!.collection("Eventos").doc(evento.id);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(evento.nombre),
            subtitle: descripcion.isNotEmpty ? Text(descripcion) : null,
            trailing: Text(
              "${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaCrearEvento(eventoEditar: eventoEditar,)));

            },
          ),
        );
      },
    );
  }
}
