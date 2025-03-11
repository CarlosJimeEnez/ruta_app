import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruta_app/home/components/add_cash.dart';
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
      body: Stack(
        children: [
          // Map placeholder (dark background)
          Container(
            height: MediaQuery.of(context).size.height,
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

          // DraggableScrollableSheet for Actions section
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.42,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Handle indicator
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Acciones',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          AddCash(),
                        ],
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

                    // Spacer to push bottom action buttons to the bottom
                    // SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  ],
                ),
              );
            },
          ),
          // Bottom action buttons
          Stack(children: [
            Positioned(
                top: MediaQuery.of(context).size.height - 140,
                left: 0,
                right: 0,
                child: const BottomActionButtons())
          ]),
        ],
      ),
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
          color: Theme.of(context).colorScheme.primary,
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
