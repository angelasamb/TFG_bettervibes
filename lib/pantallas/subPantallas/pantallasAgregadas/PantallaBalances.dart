import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/clases/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaBalances extends StatefulWidget {
  const PantallaBalances({super.key});

  @override
  State<PantallaBalances> createState() => _PantallaBalancesState();
}

class _PantallaBalancesState extends State<PantallaBalances> {
  late Future<DocumentReference?> _unidadFamiliarRef;

  @override
  void initState() {
    super.initState();
    _unidadFamiliarRef = obtenerUnidadFamiliarRefActual();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Balances",), foregroundColor: Colors.gamaColores.shade500,),
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          FutureBuilder<DocumentReference?>(
            future: _unidadFamiliarRef,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text('Unidad familiar no encontrada.'),
                );
              }

              final unidadRef = snapshot.data!;
              return _contenidoBalances(unidadRef);
            },
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

        final usuarios =
            snapshotUsuarios.data!.docs
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
                    placeholderBuilder:
                        (context) => const CircularProgressIndicator(),
                  ),
                ),
                title: Text(usuario.nombre),
                trailing: Text("${usuario.balance.toStringAsFixed(2)} €", style: TextStyle(fontSize: 16),),
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
                    await generarBizums(usuarios, unidadRef);
                    setState(() {}); // Forzar recarga
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: unidadRef.collection("Bizums").snapshots(),
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
                            data["personaPaga"],
                            data["personaRecibe"],
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const SizedBox.shrink();
                            final nombres = snapshot.data!;
                            return CheckboxListTile(
                              value: data['hecho'] ?? false,
                              title: Text('${nombres[0]} → ${nombres[1]}'),
                              onChanged: (value) async {
                                await actualizarEstadoBizum(
                                  bizumDoc.reference,
                                  data,
                                  value!,
                                );
                              },
                            );
                          },
                        );
                      }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  generarBizums(List<Usuario> usuarios, DocumentReference<Object?> unidadRef) {}

  obtenerNombresUsuarios(data, data2) {}

  actualizarEstadoBizum(
    DocumentReference<Object?> reference,
    Map<String, dynamic> data,
    bool bool,
  ) {}
}
