import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("✅ Firebase conectado correctamente");
  } catch (e) {
    print("❌ Error al conectar Firebase: $e");
  }
  runApp(MyApp());
}
/*
// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unidades Familiares',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UnidadesFamiliaresScreen(),
    );
  }
}

// Pantalla que consulta Firestore
class UnidadesFamiliaresScreen extends StatelessWidget {
  final String unidadFamiliarID = 'unidadFamiliarID'; // Reemplaza con el ID real

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('UnidadesFamiliares')
        .doc(unidadFamiliarID);

    return Scaffold(
      appBar: AppBar(title: Text('Unidad Familiar')),
      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No se encontró la unidad'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${data['nombre']}'),
                Text('Contraseña: ${data['contrasenia']}'),
                Text('Usuarios: ${(data['usuariosID'] as List).join(', ')}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
*/


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
          bottomNavigationBarTheme: BottomNavigationBarThemeData( // Color de fondo claro
            selectedItemColor: Colors.deepPurple[300],
            // Ítem seleccionado visible
            unselectedItemColor: Colors.grey,
          )
      ),
      home: PantallaPrincipal(title: 'Titulo'),
    );
  }

}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _PantallaPrincipalState();

}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _counter = 0; // Generalmente, los campos del estado se suelen declarar
  // como privados, con un guión bajo (_) delante del nombre.
  void _onItemTapped(int index2) {
    setState(() {
      // Modifica el estado, indicando a Flutter que ha habido
      // cambios en este y provocando el consecuente reibujado, es decir
      // una nueva invocación al método build de este widget.
      _counter=index2;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _counter,
        onTap: _onItemTapped,
        // Ítems no seleccionados
        items: const[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Principal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Horario'),

          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendario'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_rounded),
              label: 'Finanzas'),
        ],
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.pink[200],
            child: Text(
              'Content for the ${_counter == 0 ? "Principal" : _counter == 1 ? "Horario" : _counter == 2 ? "Calendario" : "Finanzas"} tab',
              style: TextStyle(fontSize: 20),
            ),
          ),

          // You can add more content containers here
        ],
      ),
    );

  }
}
