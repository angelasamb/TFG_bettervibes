import 'package:flutter/material.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaInicio.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/PantallaTODO.dart';
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
    PantallaTODO(),
    PantallaEventos(),
    PantallaConfiguracion(),
  ];

  void _alElegirVentana(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {//mover el appbar a cada pantalla para que el fondo pueda ocupar todo el espacio
    return Scaffold(

      body: _pantallas[_indiceSeleccionado],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSeleccionado,
        onTap: _alElegirVentana,
        selectedItemColor: Colors.gamaColores.shade400,
        unselectedItemColor: Colors.gamaColores.shade50,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time_filled), label: 'TODO'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}
