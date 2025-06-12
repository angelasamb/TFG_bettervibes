import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaBalances.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaEditarPago.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PantallaPagos extends StatefulWidget {
  const PantallaPagos({super.key});

  @override
  State<PantallaPagos> createState() => _PantallaPagosState();
}

class _PantallaPagosState extends State<PantallaPagos> {
  late Future<DocumentReference?> _unidadFamiliarRefFuture;

  @override
  void initState() {
    super.initState();
    _unidadFamiliarRefFuture = obtenerUnidadFamiliarRefActual();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Pagos"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.gamaColores.shade500,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaEditarPago()),
              );
            },
            tooltip: "Añadir nuevo pago",
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12,),
          FloatingActionButton(
            heroTag: "btnAñadirPago",
            backgroundColor: Colors.gamaColores.shade500,
            foregroundColor: Colors.white,
            onPressed: () {
             /* Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PantallaBalances()),
              );*/
            },
            tooltip: "Balances",
            child: const Icon(Icons.add),
          ),
        ],
      ),

      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<DocumentReference?>(
                  future: _unidadFamiliarRefFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print("Error SNAPSHOT FutureBuilder: ${snapshot.error}");
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final unidadFamiliarRef = snapshot.data;
                    if (unidadFamiliarRef == null) {
                      return const Center(
                        child: Text("No se encontró unidad familiar"),
                      );
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream:
                          unidadFamiliarRef
                              .collection("Pagos")
                              .orderBy("timestamp", descending: true)
                              .snapshots(),
                      builder: (context, pagosSnapshot) {
                        if (pagosSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (pagosSnapshot.hasError) {
                          print("Error SNAPSHOT StreamBuilder: ${pagosSnapshot.error}");

                          return Center(
                            child: Text("Error: ${pagosSnapshot.error}"),
                          );
                        }

                        final pagosDocs = pagosSnapshot.data?.docs ?? [];
                        if (pagosDocs.isEmpty) {
                          return const Center(
                            child: Text("No hay pagos registrados."),
                          );
                        }

                        return ListView.builder(
                          itemCount: pagosDocs.length,
                          itemBuilder: (context, index) {
                            final pagoDoc = pagosDocs[index];
                            final pagoData = pagoDoc.data()! as Map<String, dynamic>;

                            final descripcion = pagoData["descripcion"] ?? "Sin descripción";
                            final precio = pagoData["precio"]?.toString() ?? "N/A";
                            final timestamp = pagoData["timestamp"] as Timestamp?;
                            final fecha = timestamp != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                              timestamp.millisecondsSinceEpoch,
                            )
                                : null;
                            return SingleChildScrollView(
                              child: ListTile(
                                title: Text(descripcion),
                                subtitle: Text(
                                  "Precio: $precio €\nFecha: ${fecha != null ? fecha.toLocal().toString().split(' ')[0] : "N/A"}",
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => PantallaEditarPago(
                                            idPago: pagoDoc.id,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}