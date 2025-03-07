import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruta_app/home/components/app_bar.dart';
import '../controllers/balance_controller.dart';

import 'components/transaction_items.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Use GetX controller instead of local state
  final BalanceController balanceController = Get.put(BalanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Map placeholder (dark background)
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Colors.black87,
            child: Stack(
              children: [
                // Price Display centrado pero un poco arriba
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Obx(() =>
                        PriceDisplay(amount: balanceController.balance.value)),
                  ),
                ),
              ],
            ),
          ),

          // Actions section
          Expanded(
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Acciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Transaction list - now clickable to reduce balance
                  TransactionItem(
                    title: 'Nuevo Viaje',
                    subtitle: 'Hoy',
                    amount: -7.50,
                    icon: Icons.person,
                    isClickable: true, // Make it clickable
                  ),

                  // Bottom action buttons
                  const Spacer(),
                  const BottomActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Add a floating action button for testing
    );
  }
}

// Price display component
class PriceDisplay extends StatelessWidget {
  final double amount;

  const PriceDisplay({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 42, 107, 58),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '\$${amount.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
