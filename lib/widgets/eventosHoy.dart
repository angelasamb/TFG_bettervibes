import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListaEventosHoy extends StatefulWidget {
  const ListaEventosHoy({super.key});

  @override
  State<ListaEventosHoy> createState() => _ListaEventosHoyState();
}

class _ListaEventosHoyState extends State<ListaEventosHoy> {
  List<Map<String, dynamic>> eventosFiltrados = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarEventosHoy();
  }

  Future<void> _cargarEventosHoy() async {
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

      final hoy = DateTime.now();
      final hoyInicio = DateTime(hoy.year, hoy.month, hoy.day);
      final hoyFin = hoyInicio.add(const Duration(days: 1));

      final eventosHoyFiltrados = eventos.where((evento) {
        if (evento is! Map<String, dynamic>) return false;

        final Timestamp? ts = evento['timestamp'];
        final DocumentReference? usuarioEventoRef = evento['usuarioRef'];

        if (ts == null) return false;

        final fechaEvento = ts.toDate();

        if (fechaEvento.isBefore(hoyInicio) || !fechaEvento.isBefore(hoyFin)) {
          return false;
        }

        if (usuarioEventoRef == null) return true;

        return usuarioEventoRef.id == user.uid;
      }).toList();

      setState(() {
        eventosFiltrados = eventosHoyFiltrados.cast<Map<String, dynamic>>();
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
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (eventosFiltrados.isEmpty) {
      return const Center(child: Text("No hay eventos para hoy"));
    }

    return ListView.builder(
      itemCount: eventosFiltrados.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final evento = eventosFiltrados[index];

        final nombre = evento['nombre'] ?? 'Sin nombre';
        final descripcion = evento['descripcion'] ?? '';
        final timestamp = evento['timestamp'] as Timestamp;
        final fechaHora = timestamp.toDate();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(nombre),
            subtitle: descripcion.isNotEmpty ? Text(descripcion) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // que no ocupe todo el espacio
              children: [
                Text(
                  "${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Editar evento',
                  onPressed: () {
                    // TODO: Lógica para editar evento
                    print('Editar evento: $nombre');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar evento',
                  onPressed: () {
                    // TODO: Lógica para eliminar evento
                    print('Eliminar evento: $nombre');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
