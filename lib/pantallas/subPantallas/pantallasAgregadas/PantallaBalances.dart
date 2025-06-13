import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/clases/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../funcionalidades/FuncionesPagos.dart';
import '../../../funcionalidades/FuncionesUsuario.dart';

class PantallaBalances extends StatefulWidget {
  const PantallaBalances({super.key});

  @override
  State<PantallaBalances> createState() => _PantallaBalancesState();
}

class _PantallaBalancesState extends State<PantallaBalances> {
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
        title: const Text("Balances"),
        centerTitle: true,
        foregroundColor: Colors.gamaColores.shade500,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            "assets/imagenes/fondo1.svg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: FutureBuilder<DocumentReference?>(
              future: _unidadFamiliarRefFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text("Unidad familiar no encontrada."),
                  );
                }

                final unidadRef = snapshot.data!;
                return _contenidoBalances(unidadRef);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenidoBalances(DocumentReference unidadRef) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("Usuario")
              .where("unidadFamiliarRef", isEqualTo: unidadRef)
              .snapshots(),
      builder: (context, snapshotUsuarios) {
        if (snapshotUsuarios.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshotUsuarios.hasData || snapshotUsuarios.data!.docs.isEmpty) {
          return const Center(
            child: Text("No hay usuarios en la unidad familiar."),
          );
        }

        final usuariosDocs = snapshotUsuarios.data!.docs;
        final usuarios =
            usuariosDocs
                .map(
                  (doc) =>
                      Usuario.fromFirestore(doc.data() as Map<String, dynamic>),
                )
                .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Balance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...usuarios.map(
              (usuario) => ListTile(
                leading: ClipOval(
                  child: SvgPicture.asset(
                    usuario.fotoPerfil,
                    width: 40,
                    height: 40,
                  ),
                ),
                title: Text(usuario.nombre),
                trailing: Text(
                  "${usuario.balance.toStringAsFixed(2)} €",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bizums",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: "Generar Bizums",
                  onPressed: () async {
                    generarBizums();
                    setState(() {}); // Forzar recarga
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  unidadRef
                      .collection("Bizums")
                      .where("hecho", isEqualTo: false)
                      .snapshots(),
              builder: (context, snapshotBizums) {
                if (snapshotBizums.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bizums = snapshotBizums.data?.docs ?? [];

                return Column(
                  children:
                      bizums.map((bizumDoc) {
                        final data = bizumDoc.data() as Map<String, dynamic>;
                        return FutureBuilder<List<String>>(
                          future: obtenerNombresUsuarios(
                            data["personaPaga"] as DocumentReference,
                            data["personaRecibe"] as DocumentReference,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const SizedBox.shrink();
                            final nombres = snapshot.data!;
                            return CheckboxListTile(
                              value: data["hecho"] ?? false,
                              title: Text("${nombres[0]} debe a ${nombres[1]} ${(data["cantidad"] as num).toStringAsFixed(2)}€",
                                style: TextStyle(fontSize: 16),
                              ),
                              onChanged: (value) async {
                                final confirmacion = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Confirmar Bizum"),
                                      content: const Text(
                                        "¿Estás seguro de que quieres marcar este Bizum como realizado?",
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancelar"),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                        ),
                                        ElevatedButton(
                                          child: const Text("Confirmar"),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmacion == true) {
                                  await actualizarEstadoBizum(
                                    bizumDoc.reference,
                                    data,
                                    value!,
                                  );
                                }
                                ;
                              },
                            );
                          },
                        );
                      }).toList(),
                );
              },
            ),
            // Bizums HECHOS
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bizums realizados",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: unidadRef.collection("Bizums").where("hecho", isEqualTo: true).snapshots(),
                      builder: (context, snapshotBizumsHechos) {
                        if (snapshotBizumsHechos.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final bizumsHechos = snapshotBizumsHechos.data?.docs ?? [];

                        if (bizumsHechos.isEmpty) {
                          return const Text("No hay Bizums realizados aún.");
                        }
                        final ordenados = List.from(bizumsHechos)
                          ..sort((a, b) {
                            final tsA = (a["timestamp"] as Timestamp).toDate();
                            final tsB = (b["timestamp"] as Timestamp).toDate();
                            return tsB.compareTo(tsA);
                          });
                        return Column(
                          children: ordenados.map((bizumDoc) {
                            final data = bizumDoc.data() as Map<String, dynamic>;
                            return FutureBuilder<List<String>>(
                              future: obtenerNombresUsuarios(
                                data["personaPaga"] as DocumentReference,
                                data["personaRecibe"] as DocumentReference,
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox.shrink();
                                final nombres = snapshot.data!;
                                return ListTile(
                                  title: Text(
                                    "${nombres[0]} pagó a ${nombres[1]} ${(data["cantidad"] as num).toStringAsFixed(2)}€",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          ],
        );
      },
    );
  }
}
