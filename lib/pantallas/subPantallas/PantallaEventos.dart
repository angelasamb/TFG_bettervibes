import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
      appBar: AppBar(title: const Text('Eventos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
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
        ),
      ),
    );
  }
}
