import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showErrorDialog() {
  Get.dialog(
    AlertDialog(
      backgroundColor: const Color.fromARGB(162, 190, 5, 5),
      title: Text('Error', style: TextStyle(color: Colors.white, fontSize: 24)),
      content: Text('Ingrese un monto válido',
          style: TextStyle(color: Colors.white, fontSize: 18)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(47, 36, 36, 36),
          ),
          onPressed: () => Get.back(),
          child:
              Text('OK', style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ],
    ),
  );
}
