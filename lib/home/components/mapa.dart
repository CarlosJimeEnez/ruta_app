import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';

// Singleton para acceder a la instancia del mapa desde cualquier parte
class MapaController {
  static final MapaController _instance = MapaController._internal();
  factory MapaController() => _instance;
  MapaController._internal();

  _MapaViewState? _state;

  void registerState(_MapaViewState state) {
    _state = state;
  }

  void goToCurrentLocation() {
    _state?._goToCurrentLocation();
  }
}

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView>
    with AutomaticKeepAliveClientMixin {
  // Registrar el estado con el controlador
  @override
  void initState() {
    super.initState();
    MapaController().registerState(this);
    _determinePosition().then((_) {
      _goToCurrentLocation();
    });
    // Ejecutar la obtención de posición con un pequeño retraso para permitir que la UI se renderice primero
    Future.delayed(Duration.zero, _determinePosition);
  }

  @override
  bool get wantKeepAlive => true;
  bool _gesturesEnabled = true;
  bool _isLoading = true;
  double? _userLatitude;
  double? _userLongitude;
  final List<Point> _userLocationPoints = [];
  StreamSubscription<geo.Position>? _positionStreamSubscription;

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
          if (!mounted) {
            return; // Verificar nuevamente si el widget sigue montado
          }
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
      final geo.Position currentPosition =
          await geo.Geolocator.getCurrentPosition(
              desiredAccuracy: geo.LocationAccuracy.high);

      if (!mounted) return;

      // Actualizar la ubicación con la posición actual
      setState(() {
        _userLatitude = currentPosition.latitude;
        _userLongitude = currentPosition.longitude;
        _isLoading = false;
      });

      // Actualizar el punto en el mapa
      _updateUserLocationPoints();

      // Usar el stream de posición para actualizar en tiempo real la ubicación
      _positionStreamSubscription =
          geo.Geolocator.getPositionStream().listen((geo.Position position) {
        if (!mounted) return;

        debugPrint(
            'Nueva posición recibida: ${position.latitude}, ${position.longitude}');
        setState(() {
          _userLatitude = position.latitude;
          _userLongitude = position.longitude;
          _isLoading = false;
        });

        // Actualizar los puntos para el CircleLayer
        _updateUserLocationPoints();
      });
    } catch (e) {
      debugPrint('Error al obtener la ubicación: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Controlador del mapa
  MapController? _mapController;

  // Método para ir a la ubicación actual
  Future<void> _goToCurrentLocation() async {
    if (_userLatitude == null ||
        _userLongitude == null ||
        _mapController == null) {
      debugPrint(
          'No se puede ir a la ubicación: ubicación no disponible o mapa no inicializado.');
      return;
    }

    try {
      // Usar el controlador para animar el mapa a la ubicación actual sin reconstruir el widget
      await _mapController!.animateCamera(
        center: Position(_userLongitude!, _userLatitude!),
        zoom: 17,
        nativeDuration: const Duration(milliseconds: 500),
      );
      debugPrint('Mapa centrado en la ubicación actual.');
    } catch (e) {
      debugPrint('Error moviendo el mapa a la ubicación actual: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    // Posición inicial del mapa (por defecto si no hay ubicación del usuario)
    final Position initialPosition = Position(9.17, 47.68);

    // Si tenemos la ubicación del usuario, usarla como posición inicial
    final Position mapPosition =
        (_userLatitude != null && _userLongitude != null)
            ? Position(_userLongitude!, _userLatitude!)
            : initialPosition;

    // Usar una clave estática para el mapa para evitar reconstrucciones innecesarias
    const mapKey = ValueKey('map-static-key');

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
              layers: [
                // Agregar una capa de sombreado para aproximar la precisión de la ubicación
                if (_userLocationPoints.isNotEmpty)
                  CircleLayer(
                    points: _userLocationPoints,
                    color: const Color(0xFF03788D).withOpacity(
                        0.2), // Color azul muy transparente para el sombreado
                    radius: 30, // Radio grande para el sombreado de precisión
                    strokeColor:
                        Colors.transparent, // Sin borde para el sombreado
                    strokeWidth: 0,
                  ),
                // Agregar el CircleLayer para mostrar la ubicación exacta del usuario
                if (_userLocationPoints.isNotEmpty)
                  CircleLayer(
                    points: _userLocationPoints,
                    color: const Color(0xFF03788D)
                        .withOpacity(0.5), // Color azul semitransparente
                    radius: 12, // Tamaño del círculo
                    strokeColor:
                        Colors.white, // Borde blanco para mejorar visibilidad
                    strokeWidth: 2, // Grosor del borde
                  ),
              ],
              onEvent: (event) {
                if (event case MapEventClick()) {
                  // update the map widget using Flutters' state management
                  setState(() {
                    _gesturesEnabled = !_gesturesEnabled;
                  });
                } else if (event case MapEventIdle()) {
                  // Cuando el mapa termina de moverse y queda inactivo
                  debugPrint('Mapa detenido en una nueva posición');
                }
              },
              onMapCreated: (controller) {
                _mapController = controller;
                debugPrint(
                    'Mapa creado con posición: ${mapPosition.lng}, ${mapPosition.lat}');
                // Intentar actualizar los puntos de ubicación si ya tenemos las coordenadas
                if (_userLatitude != null && _userLongitude != null) {
                  _updateUserLocationPoints();
                }
              },
              onStyleLoaded: (style) {
                debugPrint('Map loaded');
                // Intentar actualizar los puntos de ubicación si ya tenemos las coordenadas
                if (_userLatitude != null && _userLongitude != null) {
                  _updateUserLocationPoints();
                }
              },
            ),
          ),

          // Indicador de carga mientras se obtiene la ubicación
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // El marcador se maneja ahora directamente en el mapa a través del CircleLayer

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

  // Método para actualizar el marcador de ubicación del usuario en el mapa
  void _updateUserLocationPoints() {
    if (_userLatitude == null || _userLongitude == null) {
      debugPrint('No se puede actualizar la ubicación: faltan datos.');
      return;
    }

    try {
      // Actualizar la lista de puntos para el CircleLayer sin forzar una reconstrucción completa
      // Solo actualizamos el estado si realmente hay un cambio en los puntos
      final newPoint = Point(
        coordinates: Position(_userLongitude!, _userLatitude!),
      );

      // Verificar si necesitamos actualizar los puntos
      bool needsUpdate = _userLocationPoints.isEmpty;
      if (!needsUpdate && _userLocationPoints.isNotEmpty) {
        final currentPoint = _userLocationPoints.first;
        needsUpdate = currentPoint.coordinates.lat != _userLatitude! ||
            currentPoint.coordinates.lng != _userLongitude!;
      }

      if (needsUpdate) {
        setState(() {
          _userLocationPoints.clear();
          _userLocationPoints.add(newPoint);
        });
        debugPrint(
            'Punto de ubicación actualizado en: $_userLatitude, $_userLongitude');
      }
    } catch (e) {
      debugPrint('Error actualizando el punto de ubicación: $e');
    }
  }

  @override
  void dispose() {
    // Cancelar la suscripción al stream de posición
    _positionStreamSubscription?.cancel();
    // Limpiar recursos cuando el widget se destruye
    super.dispose();
  }
}
