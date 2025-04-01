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

  @override
  Widget build(BuildContext context) {
    final BalanceController balanceController = Get.find<BalanceController>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          // Left section with icon
          Container(
            padding: const EdgeInsets.all(16),
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
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
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
                    ? () => balanceController.reduceBalance()
                    : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      // Amount
                      Text(
                        '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(1)}\$',
                        style: TextStyle(
                          color: amount >= 0 ? Colors.green : Colors.red,
                          fontSize: 18,
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
