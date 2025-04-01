import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruta_app/edit_cash_screen/edit_screen.dart';
import 'package:ruta_app/home/components/add_cash.dart';
import 'package:ruta_app/home/components/app_bar.dart';
import 'package:ruta_app/home/components/transaction_items.dart';

import '../controllers/balance_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Use GetX controller instead of local state
  final BalanceController balanceController = Get.put(BalanceController());
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final RxBool _showBackToTopButton = false.obs;
  // Store the scroll controller as a class variable
  ScrollController? _listScrollController;

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'Ayer' : 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? 'Hace 1 hora'
          : 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? 'Hace 1 minuto'
          : 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Justo ahora';
    }
  }

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
            controller: _sheetController,
            initialChildSize: 0.45,
            minChildSize: 0.42,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.7, 0.9],
            builder: (BuildContext context, ScrollController scrollController) {
              // Store the scroll controller for later use
              _listScrollController = scrollController;
              // Add listener to the scroll controller
              scrollController.addListener(() {
                if (scrollController.offset >= 300 &&
                    !_showBackToTopButton.value) {
                  _showBackToTopButton.value = true;
                } else if (scrollController.offset < 300 &&
                    _showBackToTopButton.value) {
                  _showBackToTopButton.value = false;
                }
              });

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
                    const SizedBox(height: 10),
                    TransactionItem(
                        title: 'Nuevo Viaje',
                        subtitle: 'Hoy',
                        amount: -7.5,
                        icon: Icons.directions_bus,
                        isClickable: true),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        color: Colors.grey.shade800,
                        thickness: 2,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Historial",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19.2,
                                fontWeight: FontWeight.bold,
                              )),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward,
                                size: 24,
                                color: Color.fromARGB(255, 134, 134, 134)),
                            onPressed: () {
                              // Add edit functionality here
                              _sheetController.animateTo(
                                0.9, // Tamaño máximo
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    const SizedBox(height: 10),
                    // Transaction list - dynamically updated
                    Obx(() => balanceController.transactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No hay transacciones todavía',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: balanceController.transactions.length,
                            itemBuilder: (context, index) {
                              // Get transaction data in reverse order (newest first)
                              final transaction =
                                  balanceController.transactions[
                                      balanceController.transactions.length -
                                          1 -
                                          index];
                              final DateTime transactionDate =
                                  DateTime.parse(transaction['date']);
                              final String timeAgo =
                                  _getTimeAgo(transactionDate);

                              // Convert icon string to IconData
                              IconData transactionIcon =
                                  Icons.account_balance_wallet;
                              if (transaction['icon'] == 'directions_bus') {
                                transactionIcon = Icons.directions_bus;
                              }

                              return TransactionItem(
                                title: transaction['type'] == 'VIAJE'
                                    ? 'Viaje'
                                    : 'Recarga',
                                subtitle: timeAgo,
                                amount: transaction['amount'],
                                icon: transactionIcon,
                                isClickable: false,
                              );
                            },
                          )),
                  ],
                ),
              );
            },
          ),

          // Back to top button
          Obx(() => Positioned(
                bottom: 20,
                right: 20,
                child: AnimatedOpacity(
                  opacity: _showBackToTopButton.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showBackToTopButton.value
                      ? FloatingActionButton(
                          mini: true,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            // Use the stored scroll controller
                            _listScrollController?.animateTo(
                              0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              )),

          // Bottom action buttons
        ],
      ),
      bottomNavigationBar: const BottomActionButtons(),
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money,
            color: const Color.fromARGB(255, 255, 255, 255),
            size: 35,
          ),
          Text(
            '${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit,
                size: 24, color: Color.fromARGB(255, 134, 134, 134)),
            onPressed: () {
              Get.to(() => const EditScreen());
              // Add edit functionality here
            },
          ),
        ],
      ),
    );
  }
}
