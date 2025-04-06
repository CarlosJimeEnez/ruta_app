import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/balance_controller.dart';
import '../../transfer_screen/transfer_screen.dart';

class AddCash extends StatelessWidget {
  final bool isClickable;
  final double amount;

  const AddCash({
    super.key,
    this.isClickable = true,
    this.amount = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final BalanceController balanceController = Get.find<BalanceController>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isClickable
            ? () {
                //balanceController.addBalance(amount);
                Get.to(() => const TransferWidget());
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.add,
            color: Colors.greenAccent,
            size: 32,
          ),
        ),
      ),
    );
  }
}
