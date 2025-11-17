import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:kaskredit_1/features/expenses/presentation/providers/expense_providers.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton provider expenses
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pengeluaran"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nanti kita buat halaman AddExpense
          // context.push('/expenses/add');
        },
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(
              child: Text("Belum ada pengeluaran. Tekan tombol + untuk menambah."),
            );
          }

          // Tampilkan ListView
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.payment),
                  ),
                  title: Text(expense.description),
                  subtitle: Text(
                    DateFormat('d MMM yyyy').format(expense.expenseDate),
                  ),
                  trailing: Text(
                    Formatters.currency.format(expense.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red, // Pengeluaran kita tandai merah
                    ),
                  ),
                  onTap: () {
                    // Nanti bisa dibuat halaman edit/detail
                  },
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(
          child: Text("Error memuat pengeluaran: $err"),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}