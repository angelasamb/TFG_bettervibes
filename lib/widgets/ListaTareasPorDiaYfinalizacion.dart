import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/clases/Tareas.dart';
import 'package:tfg_bettervibes/clases/TipoTareas.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';

class ListaTareasPorDia extends StatefulWidget {
  final DateTime fecha;
  final bool mostrarRealizadas;

  const ListaTareasPorDia({
    super.key,
    required this.fecha,
    required this.mostrarRealizadas,
  });

  @override
  State<ListaTareasPorDia> createState() => _ListaTareasPorDiaState();
}

class _ListaTareasPorDiaState extends State<ListaTareasPorDia> {
  List<Map<String, dynamic>> tareasConTipo = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarTareasDelDia();
  }

  @override
  void didUpdateWidget(covariant ListaTareasPorDia oldWidget) {
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

      final docs = querySnapshot.docs;

      final List<Map<String, dynamic>> resultado = [];

      for (var doc in docs) {
        final tarea = Tareas.fromFirestore(doc.data());

        final tipoSnapshot = await tarea.tipoTareaRef.get();
        if (!tipoSnapshot.exists) continue;

        final tipo = TipoTareas.fromFirestore(tipoSnapshot.data() as Map<String, dynamic>);

        resultado.add({
          'tarea': tarea,
          'tipo': tipo,
        });
      }
// Para ordenar por hora
      resultado.sort((a, b) {
        final t1 = a['tarea'] as Tareas;
        final t2 = b['tarea'] as Tareas;
        return t1.timestamp.compareTo(t2.timestamp);
      });

      setState(() {
        tareasConTipo = resultado;
        cargando = false;
      });

    }catch (e, stackTrace) {
  print("Error cargando tareas: $e");
  print(stackTrace);
  setState(() {
  error = "Error al cargar tareas: $e";
  cargando = false;
  });
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final tarea = tareasConTipo[index]['tarea'] as Tareas;
        final tipo = tareasConTipo[index]['tipo'] as TipoTareas;
        final hora = tarea.timestamp.toDate();

        final horaFormateada =
            "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            leading: Icon(
              widget.mostrarRealizadas ? Icons.check_circle : Icons.radio_button_unchecked,
              color: widget.mostrarRealizadas ? Colors.green : Colors.orange,
            ),
            title: Text("${tipo.nombre} - $horaFormateada"),
            subtitle: tarea.descripcion.isNotEmpty ? Text(tarea.descripcion) : null,
          ),
        );
      },
    );
  }
}
