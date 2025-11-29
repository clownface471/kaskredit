import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/shared/models/expense.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final ExpenseController controller = Get.put(ExpenseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengeluaran"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.ADD_EXPENSE),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          Obx(() {
            final selectedMonth = controller.selectedMonth.value ?? DateTime.now();
            
            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        final newMonth = DateTime(
                          selectedMonth.year,
                          selectedMonth.month - 1,
                        );
                        controller.setSelectedMonth(newMonth);
                      },
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        final now = DateTime.now();
                        if (selectedMonth.year < now.year ||
                            (selectedMonth.year == now.year &&
                                selectedMonth.month < now.month)) {
                          final newMonth = DateTime(
                            selectedMonth.year,
                            selectedMonth.month + 1,
                          );
                          controller.setSelectedMonth(newMonth);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          // Total expenses card
          Obx(() {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.red.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down, color: Colors.red, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pengeluaran',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.currency(controller.totalExpenses),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 16),

          // Expense list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.expenses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredExpenses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, 
                           size: 64, 
                           color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada pengeluaran bulan ini",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.loadExpenses();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = controller.filteredExpenses[index];
                    return _ExpenseCard(expense: expense);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.EDIT_EXPENSE,
          arguments: expense,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              
              // Expense info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy').format(expense.expenseDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Amount
              Text(
                Formatters.currency(expense.amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
