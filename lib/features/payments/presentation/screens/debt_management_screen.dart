import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/customers/presentation/controllers/customer_controller.dart';
import 'package:kaskredit_1/features/payments/presentation/widgets/payment_dialog.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';

class DebtManagementScreen extends StatelessWidget {
  const DebtManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan CustomerController untuk list pelanggan
    final controller = Get.put(CustomerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Utang"),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.customers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter pelanggan yang punya utang
        final debtors = controller.customers.where((c) => c.totalDebt > 0).toList();
        // Sort dari utang terbesar
        debtors.sort((a, b) => b.totalDebt.compareTo(a.totalDebt));

        if (debtors.isEmpty) {
          return const Center(
            child: Text("Luar biasa! Tidak ada pelanggan yang berutang."),
          );
        }

        return ListView.builder(
          itemCount: debtors.length,
          itemBuilder: (context, index) {
            final customer = debtors[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : "?"),
                ),
                title: Text(customer.name),
                subtitle: Text(
                  "Total Utang: ${Formatters.currency.format(customer.totalDebt)}",
                  style: const TextStyle(color: Colors.red),
                ),
                trailing: ElevatedButton(
                  child: const Text("Bayar"),
                  onPressed: () => _showPaymentDialog(context, customer),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showPaymentDialog(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PaymentDialog(customer: customer),
    );
  }
}