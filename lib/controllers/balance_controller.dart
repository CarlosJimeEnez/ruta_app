import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruta_app/transfer_screen/components/custom_dialog.dart';

class BalanceController extends GetxController {
  // Observable balance
  var balance = 12.0.obs;
  var isLoading = true.obs;
  var peoples = 1.obs;
  // Observable transaction list
  var transactions = <Map<String, dynamic>>[].obs;

  // Keys for SharedPreferences
  final String balanceKey = 'user_balance';
  final String transactionsKey = 'balance_transactions';
  final String peoplesKey = 'user_peoples';

  @override
  void onInit() {
    super.onInit();
    loadBalance();
    loadTransactions();
  }

  // Load balance from persistent storage
  void loadBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBalance = prefs.getDouble(balanceKey);
      if (savedBalance != null) {
        balance.value = savedBalance;
      }
    } catch (e) {
      print('Error cargando el saldo: $e');
      // Mantén el saldo predeterminado si hay un error
    } finally {
      isLoading.value = false;
    }
  }

  // Load transactions from persistent storage
  void loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedTransactions = prefs.getStringList(transactionsKey) ?? [];
      
      transactions.value = savedTransactions.map((transaction) {
        return jsonDecode(transaction) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error cargando las transacciones: $e');
    }
  }

  // Save balance to persistent storage
  void saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(balanceKey, balance.value);
  }

  // Method to reduce balance (for a trip)
  void reduceBalance() {
    if (balance.value >= 7.5) {
      balance.value -= 7.5;
      saveTransaction('VIAJE', -7.5);
      saveBalance();
    } else {
      showCustomDialog('Error', 'El saldo no es suficiente');
    }
  }

  // Method to add balance
  void addBalance(double amount) {
    if (amount > 0) {
      balance.value += amount;
      saveTransaction('RECARGA', amount);
      saveBalance();
    }
  }

  // Method to edit balance
  void editBalance(double newBalance) {
    if (newBalance >= 0) {
      balance.value = newBalance;
      saveBalance();
    } else {
      Get.snackbar('Error', 'El balance no puede ser negativo',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Save transaction history
  void saveTransaction(String type, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedTransactions = prefs.getStringList(transactionsKey) ?? [];

    // Create transaction record
    final transaction = {
      'type': type,
      'amount': amount,
      'balance': balance.value,
      'date': DateTime.now().toIso8601String(),
      'icon': type == 'VIAJE' ? 'directions_bus' : 'account_balance_wallet',
    };

    // Convert to JSON string and add to list
    savedTransactions.add(jsonEncode(transaction));

    // Save updated list
    await prefs.setStringList(transactionsKey, savedTransactions);
    
    // Update observable list
    transactions.add(transaction);
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> transactions = prefs.getStringList(transactionsKey) ?? [];

    return transactions.map((transaction) {
      return jsonDecode(transaction) as Map<String, dynamic>;
    }).toList();
  }
}
