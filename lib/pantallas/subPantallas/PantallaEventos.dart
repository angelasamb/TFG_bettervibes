import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';

import '../../widgets/ListaEventosPorDia.dart';

class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  DateTime _fechaSeleccionada = DateTime.now();
  CalendarFormat _formatoCalendario = CalendarFormat.month;
  String _textoFormato(CalendarFormat formato) {
    switch (formato) {
      case CalendarFormat.month:
        return 'Mes';
      case CalendarFormat.twoWeeks:
        return '2 semanas';
      case CalendarFormat.week:
        return 'Semana';
      default:
        return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/imagenes/fondo1.svg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_formatoCalendario == CalendarFormat.month) {
                          _formatoCalendario = CalendarFormat.twoWeeks;
                        } else if (_formatoCalendario == CalendarFormat.twoWeeks) {
                          _formatoCalendario = CalendarFormat.week;
                        } else {
                          _formatoCalendario = CalendarFormat.month;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black26,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _textoFormato(_formatoCalendario),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: 'es_ES',
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _fechaSeleccionada,
                    calendarFormat: _formatoCalendario,
                    selectedDayPredicate: (day) => isSameDay(day, _fechaSeleccionada),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _fechaSeleccionada = selectedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _formatoCalendario = format;
                      });
                    },
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mes',
                      CalendarFormat.twoWeeks: '2 semanas',
                      CalendarFormat.week: 'Semana',
                    },
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: TextStyle(color: Colors.redAccent),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      formatButtonTextStyle: const TextStyle(color: Colors.white),
                      titleCentered: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Eventos del día',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListaEventosPorDia(fecha: _fechaSeleccionada),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaCrearEvento(tipoActividad: "evento",),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
