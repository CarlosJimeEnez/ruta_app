import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'package:geolocator/geolocator.dart' as geo;

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  MapController? _mapController;
  bool _gesturesEnabled = true;
  bool _isLoading = true;
  double? _userLatitude;
  double? _userLongitude;
  
  @override
  void initState() {
    super.initState();
    // Ejecutar la obtención de posición con un pequeño retraso para permitir que la UI se renderice primero
    Future.delayed(Duration.zero, _determinePosition);
  }

  // Método para obtener la posición actual del usuario
  Future<void> _determinePosition() async {
    if (!mounted) return; // Verificar si el widget sigue montado
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar permisos de ubicación
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          // Permisos denegados
          if (!mounted) return; // Verificar nuevamente si el widget sigue montado
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        // Permisos denegados permanentemente
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Servicio de ubicación deshabilitado
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtener la posición actual
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);

      if (!mounted) return;
      
      // Guardar la posición actual
      final double newLatitude = position.latitude;
      final double newLongitude = position.longitude;
      
      setState(() {
        _userLatitude = newLatitude;
        _userLongitude = newLongitude;
        _isLoading = false;
      });

      // Importante: Actualizar el mapa si ya está creado
      if (_mapController != null) {
        // Forzar la reconstrucción completa del mapa para asegurar que se centre en la nueva posición
        setState(() {});
        
        // Pequeño retraso para asegurar que el mapa se haya reconstruido antes de intentar centrarlo
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          
          // Forzar otra actualización de estado para asegurar que el mapa se centre correctamente
          setState(() {});
          
          debugPrint('Centrando mapa en: $_userLongitude, $_userLatitude');
        });
      }
    } catch (e) {
      debugPrint('Error al obtener la ubicación: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para ir a la ubicación actual
  void _goToCurrentLocation() {
    // Primero actualizar la ubicación
    _determinePosition().then((_) {
      // Luego recrear el mapa con la nueva posición
      if (_userLatitude != null && _userLongitude != null && mounted) {
        // Forzar una reconstrucción completa del mapa
        setState(() {
          // Esto forzará la reconstrucción del mapa con la nueva posición
        });

        // Mostrar un mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación actualizada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Posición inicial del mapa (por defecto si no hay ubicación del usuario)
    final Position initialPosition = Position(9.17, 47.68);

    // Si tenemos la ubicación del usuario, usarla como posición inicial
    final Position mapPosition = (_userLatitude != null && _userLongitude != null)
        ? Position(_userLongitude!, _userLatitude!)
        : initialPosition;

    // Usar ValueKey para forzar la reconstrucción cuando cambian las coordenadas
    final mapKey = ValueKey('map-${_userLatitude}-${_userLongitude}');

    return Scaffold(
      body: Stack(
        children: [
          // Usar RepaintBoundary para aislar las reconstrucciones del mapa
          RepaintBoundary(
            child: MapLibreMap(
              key: mapKey, // Usar una clave que cambia con las coordenadas
              options: MapOptions(
                initCenter: mapPosition,
                initZoom: _userLatitude != null ? 17 : 3,
                gestures:
                    _gesturesEnabled ? MapGestures.all() : MapGestures.none(),
                initStyle: 'https://tiles.openfreemap.org/styles/liberty',
              ),
              onEvent: (event) {
                if (event case MapEventClick()) {
                  // update the map widget using Flutters' state management
                  setState(() {
                    _gesturesEnabled = !_gesturesEnabled;
                  });
                }
              },
              onMapCreated: (controller) {
                _mapController = controller;
                debugPrint('Mapa creado con posición: ${mapPosition.lng}, ${mapPosition.lat}');
              },
              onStyleLoaded: (style) {
                debugPrint('Map loaded');
              },
            ),
          ),

          // Indicador de carga mientras se obtiene la ubicación
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Marcador de posición personalizado (en lugar de usar capas de MapLibre)
          if (_userLatitude != null && _userLongitude != null)
            Positioned(
              // Calculamos la posición en el centro de la pantalla ya que el mapa ya está centrado en la ubicación del usuario
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(225, 3, 120, 136),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Botón para centrar en la ubicación actual (mejorado)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _goToCurrentLocation,
                backgroundColor: const Color.fromARGB(255, 3, 120, 136),
                tooltip: 'Ir a mi ubicación',
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // Limpiar recursos cuando el widget se destruye
    _mapController = null;
    super.dispose();
  }
}
