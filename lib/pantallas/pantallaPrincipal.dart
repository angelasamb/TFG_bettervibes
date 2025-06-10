import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaInicio.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaPagos.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaTareas.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaEventos.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaConfiguración.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalEstado();
}

class _PantallaPrincipalEstado extends State<PantallaPrincipal> {
  int _indiceSeleccionado = 0;
  final List<Widget> _pantallas = [
    PantallaInicio(),
    PantallaTareas(),
    PantallaEventos(),
    PantallaPagos(),
  ];

  late String unidadFamiliarNombre = "";
  void _alElegirVentana(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarUnidadFamiliar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => PantallaConfiguracion(),
          ));

        }, icon: Icon(Icons.settings), ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(unidadFamiliarNombre, style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.gamaColores.shade500,
      ),
      body: _pantallas[_indiceSeleccionado],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSeleccionado,
        onTap: _alElegirVentana,
        selectedItemColor: Colors.gamaColores.shade400,
        unselectedItemColor: Colors.gamaColores.shade50,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_filled),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Pagos',
          ),
        ],
      ),
    );
  }

  Future<void> _cargarUnidadFamiliar() async {
    final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
    final snapshot = await unidadFamiliarRef!.get();
    print(snapshot);
    final datos = snapshot.data() as Map<String, dynamic>;
    if (snapshot.exists) {
      setState(() {
        unidadFamiliarNombre = datos["nombre"] ?? "";
      });
    }
  }

}
