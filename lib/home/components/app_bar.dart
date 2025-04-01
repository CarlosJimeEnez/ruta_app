// Bottom action buttons component
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.home, 'Home'),
          _buildActionButton(Icons.map, 'Maps'),
          _buildActionButton(Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 60,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
