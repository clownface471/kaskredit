import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/customers/presentation/providers/customer_providers.dart';
import 'package:kaskredit_1/features/payments/presentation/widgets/payment_dialog.dart'; // Akan kita buat
import 'package:kaskredit_1/shared/models/customer.dart';

class DebtManagementScreen extends ConsumerWidget {
  const DebtManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Tonton" provider baru kita
    final debtorsAsync = ref.watch(customersWithDebtProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Utang"),
      ),
      body: debtorsAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(
              child: Text("Luar biasa! Tidak ada pelanggan yang berutang."),
            );
          }
          // Tampilkan daftar pelanggan yg berutang
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    child: Text(customer.name[0].toUpperCase()),
                  ),
                  title: Text(customer.name),
                  subtitle: Text(
                    "Total Utang: Rp ${customer.totalDebt.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  trailing: ElevatedButton(
                    child: const Text("Bayar"),
                    onPressed: () {
                      // Tampilkan dialog pembayaran
                      _showPaymentDialog(context, ref, customer);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  // Fungsi untuk memanggil dialog
  void _showPaymentDialog(BuildContext context, WidgetRef ref, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bottom sheet bisa tinggi
      builder: (ctx) {
        // Kita kirim 'customer' ke dialog
        return PaymentDialog(customer: customer);
      },
    );
  }
}