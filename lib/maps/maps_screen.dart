import 'package:flutter/material.dart';
import 'package:ruta_app/home/components/mapa.dart';

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapas'),
        backgroundColor: const Color.fromARGB(255, 3, 120, 136),
      ),
      body: const MapaView(),
      // Ya no se necesita la barra de navegación aquí si no es una pantalla principal
      // bottomNavigationBar: const BottomActionButtons(currentPage: NavigationPage.maps),
    );
  }
}
