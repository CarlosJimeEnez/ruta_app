import 'package:get/get.dart';

class BalanceController extends GetxController {
  // Observable balance
  var balance = 12.0.obs;

  // Method to reduce balance
  void reduceBalance(double amount) {
    balance.value -= amount;
  }

  // Method to add balance
  void addBalance(double amount) {
    balance.value += amount;
  }
}
