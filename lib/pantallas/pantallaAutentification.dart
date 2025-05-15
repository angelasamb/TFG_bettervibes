import 'package:flutter/material.dart';
class pantallaAutentification extends StatelessWidget {
  const pantallaAutentification({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/imagenes/fondo1.jpg',fit: BoxFit.cover,
          ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/imagenes/logo1.png',
                height: 120,
                ),
                const SizedBox(height: 60),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220,50),
                  ),
                  onPressed: (){
                    //TODO: Lógica del botón de inicio con google
                  },
                  icon: Image.asset('assets/imagenes/iconoGoogle.png',
                  height: 24,
                  ),
                  label: const Text('Iniciar con google'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 50),
                  ),
                  onPressed: (){
                    //TODO: Lógica del botón de inicio personalizado
                  },
                  child: const Text('Inicio sesión por correo',
                  style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}