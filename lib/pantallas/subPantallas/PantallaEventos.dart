import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tfg_bettervibes/funcionalidades/MainFunciones.dart';
import 'package:tfg_bettervibes/pantallas/subPantallas/pantallasAgregadas/PantallaCrearEvento.dart';

import '../../widgets/ListaEventosPorDiaBotones.dart';

class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  Map<DateTime, List<Map<String, dynamic>>> _eventosPorDia = {};
  DateTime _fechaSeleccionada = DateTime.now();
  CalendarFormat _formatoCalendario = CalendarFormat.month;

  String _textoFormato(CalendarFormat formato) {
    switch (formato) {
      case CalendarFormat.month:
        return "Mes";
      case CalendarFormat.twoWeeks:
        return "2 semanas";
      case CalendarFormat.week:
        return "Semana";
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.gamaColores.shade500,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PantallaCrearEvento(
                    tipoActividad: "evento",
                    fechaSeleccionada: _fechaSeleccionada,
                  ),
            ),
          ).then((_) {
            _cargarEventos();
          });
        },
        child: const Icon(Icons.add),
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
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(top: 8, right: 12),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (_formatoCalendario ==
                                    CalendarFormat.month) {
                                  _formatoCalendario = CalendarFormat.twoWeeks;
                                } else if (_formatoCalendario ==
                                    CalendarFormat.twoWeeks) {
                                  _formatoCalendario = CalendarFormat.week;
                                } else {
                                  _formatoCalendario = CalendarFormat.month;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.gamaColores.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                            eventLoader: (dia) {
                              final fechaSinHora = _normalizarFecha(dia);
                              return _eventosPorDia[fechaSinHora] ?? [];
                            },
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            locale: "es_ES",
                            firstDay: DateTime(2020),
                            lastDay: DateTime(2030),
                            focusedDay: _fechaSeleccionada,
                            calendarFormat: _formatoCalendario,
                            selectedDayPredicate:
                                (day) => isSameDay(day, _fechaSeleccionada),
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
                              CalendarFormat.month: "Mes",
                              CalendarFormat.twoWeeks: "2 semanas",
                              CalendarFormat.week: "Semana",
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
                              weekendTextStyle: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              formatButtonDecoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              formatButtonTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              titleCentered: true,
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.gamaColores.shade500,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Eventos del día",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
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
                          child: ListaEventosPorDiaBotones(
                            fecha: _fechaSeleccionada,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cargarEventos() async {
    try {
      final unidadFamiliarRef = await obtenerUnidadFamiliarRefActual();
      final idUsuario = FirebaseAuth.instance.currentUser?.uid;
      final snapshot = await unidadFamiliarRef!.collection("Eventos").get();
      final Map<DateTime, List<Map<String, dynamic>>> eventosTemp = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final usuarioRef = data["usuarioRef"];
        if (usuarioRef == null || usuarioRef.id == idUsuario) {
          final timestamp = (data["timestamp"] as Timestamp).toDate();
          final fecha = _normalizarFecha(timestamp);
          if (eventosTemp[fecha] == null) {
            eventosTemp[fecha] = [];
          }
          eventosTemp[fecha]!.add(data);
        }
      }
      setState(() {
        _eventosPorDia = eventosTemp;
      });
    } catch (e) {
      print("Error cargando eventos: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error cargando eventos: $e")));
    }
  }

  DateTime _normalizarFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }
}
