import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/shared/models/expense.dart';
import 'package:kaskredit_1/features/expenses/data/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repository = ExpenseRepository();
  
  // Reactive state
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<DateTime?> selectedMonth = Rx<DateTime?>(null);
  
  // Computed property untuk filtered expenses by month
  List<Expense> get filteredExpenses {
    if (selectedMonth.value == null) {
      return expenses;
    }
    
    final month = selectedMonth.value!;
    return expenses.where((expense) {
      return expense.expenseDate.year == month.year &&
             expense.expenseDate.month == month.month;
    }).toList();
  }

  // Total expenses for selected month
  double get totalExpenses {
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = DateTime.now();
    loadExpenses();
  }

  void loadExpenses() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;
    
    _repository.getExpenses(userId).listen(
      (expenseList) {
        expenses.value = expenseList;
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat pengeluaran: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
        );
      },
    );
  }

  void setSelectedMonth(DateTime month) {
    selectedMonth.value = month;
  }

  Future<void> addExpense(Expense expense) async {
    try {
      isLoading.value = true;
      await _repository.addExpense(expense);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pengeluaran berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambah pengeluaran: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      isLoading.value = true;
      await _repository.updateExpense(expense);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pengeluaran berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupdate pengeluaran: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus pengeluaran "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      await _repository.deleteExpense(expense.id!);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pengeluaran berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus pengeluaran: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
