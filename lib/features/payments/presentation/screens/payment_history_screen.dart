import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:kaskredit_1/features/payments/presentation/providers/payment_providers.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton provider riwayat pembayaran
    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pembayaran")),
      body: historyAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text("Belum ada pembayaran diterima."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
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
                    "Ref: ${payment.transactionId.substring(0, 6)}... \n${DateFormat('d MMM yyyy, HH:mm').format(payment.paymentDate)}",
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Gagal memuat riwayat: $e")),
      ),
    );
  }
}
