import 'package:flutter/material.dart';

// Widget para un solo elemento de la lista de vehículos/transacciones
class VehicleListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final String date;
  final Color statusColor;
  final Color iconColor;
  final Color dateColor;
  final Color titleColor;

  const VehicleListItem({
    super.key,
    this.icon = Icons.directions_bus, // Icono por defecto
    required this.title,
    required this.status,
    required this.date,
    this.statusColor = Colors.orangeAccent, // Color naranja para el estado
    this.iconColor = const Color.fromARGB(
        137, 255, 255, 255), // Color gris oscuro para el icono
    this.dateColor = Colors.grey, // Color gris para la fecha
    this.titleColor = const Color.fromARGB(
        221, 252, 252, 252), // Color casi negro para el título
  });

  @override
  Widget build(BuildContext context) {
    // Usamos Padding para añadir espacio alrededor del contenido del item
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        // Organiza los elementos horizontalmente
        children: [
          // 1. Icono a la izquierda
          Icon(
            icon,
            color: iconColor,
            size: 24.0, // Tamaño del icono
          ),
          const SizedBox(width: 16.0), // Espacio entre icono y texto

          // 2. Columna central para título y estado (expandida)
          Expanded(
            // Hace que esta columna ocupe el espacio disponible
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinea texto a la izquierda
              mainAxisSize: MainAxisSize.min, // Ajusta la altura de la columna
              children: [
                // Título (ej: "Nombre Coche")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight:
                          FontWeight.w500, // Un poco más grueso que normal
                      color: titleColor,
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Evita que el texto largo se desborde
                  ),
                ),
                const SizedBox(height: 4.0), // Pequeño espacio vertical
                // Estado (ej: "Estado")
              ],
            ),
          ),

          // 3. Fecha a la derecha
          // El Expanded anterior empuja este Text hasta el final
          Text(
            date,
            style: TextStyle(
              fontSize: 14.0,
              color: dateColor, // Color gris para la fecha
            ),
          ),
        ],
      ),
    );
  }
}
