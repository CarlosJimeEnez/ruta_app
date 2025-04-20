// Transaction item component
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/balance_controller.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final bool isClickable;
  final BalanceController balanceController = Get.find<BalanceController>();

  TransactionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.isClickable = false,
  });

  void _showconfirmationAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 27, 27, 27),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(
                color: Color.fromARGB(255, 85, 125, 151), width: 1),
          ),
          title: Text('Se actualizó el balance',
              style: const TextStyle(color: Colors.white)),
          content: Row(
            children: [
              const Text(
                'Nuevo Viaje:',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const Text(" -7.5",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
            ],
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BalanceController balanceController = Get.find<BalanceController>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          // Left section with icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade800),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '1',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),

          // Middle and right section with title, subtitle and amount
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isClickable
                    ? () {
                        // Show modal if balance was sufficient
                        double currentBalance = balanceController.balance.value;
                        if (currentBalance >= 7.5) {
                          _showconfirmationAlert(context);
                        }
                        // Check balance before reducing
                        balanceController.reduceBalance();
                      }
                    : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title and subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      // Amount
                      Text(
                        '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(1)}\$',
                        style: TextStyle(
                          color: amount >= 0 ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
