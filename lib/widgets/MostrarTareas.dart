import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ListaTareas.dart';

class MostrarTareas extends StatefulWidget {

  final DocumentReference? unidadFamiliarRef;
  final String? user;
  final int tipo;
  final CollectionReference<Map<String, dynamic>> tareasRef;

  const MostrarTareas({required this.unidadFamiliarRef,required this.user, required this.tipo, required this.tareasRef});


  @override
  State<MostrarTareas> createState() => _MostrarTareasState();
}

class _MostrarTareasState extends State<MostrarTareas> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder(
            stream: widget.tareasRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final tareas = snapshot.data!.docs;

              if (tareas.isEmpty) {
                return const Center(child: Text("No hay tareas"));
              }
              return FutureBuilder<List<Widget>>(
                future: listaTareasPorDia(context, widget.user!, widget.tipo),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error al cargar tareas ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No hay tareas disponibles"),
                    );
                  }
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView(children: snapshot.data!),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
