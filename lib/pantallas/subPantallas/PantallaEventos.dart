import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';

import '../../widgets/eventosHoy.dart';

class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  DateTime _fechaSeleccionada = DateTime.now();
  CalendarFormat _formatoCalendario = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: Colors.gamaColores.shade100,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Scroll vertical principal
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.gamaColores.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.white),
                    titleCentered: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Título Eventos hoy
              const Text(
                'Eventos hoy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Listado con altura fija y scroll interno
              Container(
                height: 300, // Altura fija (ajusta a lo que quieras)
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
                child: ListaEventosHoy(), // Debe ser un widget con ListView o similar
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.gamaColores.shade100,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaCrearEvento(fechaSeleccionada: _fechaSeleccionada),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
