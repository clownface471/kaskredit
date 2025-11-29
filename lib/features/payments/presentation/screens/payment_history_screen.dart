import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:kaskredit_1/features/payments/presentation/controllers/payment_history_controller.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(PaymentHistoryController());

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pembayaran")),
      body: Obx(() {
        if (controller.isLoading.value && controller.payments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.payments.isEmpty) {
          return const Center(child: Text("Belum ada pembayaran diterima."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.payments.length,
          itemBuilder: (context, index) {
            final payment = controller.payments[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.attach_money, color: Colors.white),
                ),
                title: Text(
                  "Pembayaran dari: ${payment.customerName}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Ref: ${payment.transactionId.length > 8 ? payment.transactionId.substring(0, 8) + '...' : payment.transactionId}\n${DateFormat('d MMM yyyy, HH:mm').format(payment.paymentDate)}",
                ),
                trailing: Text(
                  Formatters.currency.format(payment.paymentAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}