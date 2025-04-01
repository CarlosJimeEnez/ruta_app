import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruta_app/transfer_screen/components/error_dialog.dart';
import '../controllers/balance_controller.dart';

class TransferWidget extends StatefulWidget {
  const TransferWidget({super.key});

  @override
  State<TransferWidget> createState() => _TransferWidget();
}

class _TransferWidget extends State<TransferWidget> {
  final TextEditingController _amountController = TextEditingController();
  final BalanceController _balanceController = Get.find<BalanceController>();

  void _addBalance() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      showErrorDialog();
      return;
    }
    _balanceController.addBalance(amount);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title:
            const Text('Nuevo balance', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cuánto vas a agregar?',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Monto actual: ${_balanceController.balance.value}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 170, 167, 167)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBalance,
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: const Text('Agregar',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
