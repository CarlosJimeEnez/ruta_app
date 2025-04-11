import 'package:flutter/material.dart';
import 'package:ruta_app/transfer_screen/components/error_dialog.dart';
import '../controllers/balance_controller.dart';
import 'package:get/get.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final BalanceController _balanceController = Get.find<BalanceController>();
  final TextEditingController _amountController = TextEditingController();

  void _saveBalance() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 0) {
      showErrorDialog();
      return;
    }
    _balanceController.editBalance(amount);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Editar balance',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nuevo balance',
                style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 10),
            Text("Ingrese un nuevo balance",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 170, 167, 167))),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              autofocus: true,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade700,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade700,
                    width: 2,
                  ),
                ),
                hintText: 'Ingrese el monto',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 20),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text('Monto actual: ${_balanceController.balance.value}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 170, 167, 167))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveBalance();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: const Text('Guardar',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        icon: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}
