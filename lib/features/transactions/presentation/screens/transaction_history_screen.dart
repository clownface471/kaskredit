import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:kaskredit_1/features/transactions/presentation/controllers/transaction_history_controller.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(TransactionHistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return const Center(child: Text("Belum ada transaksi."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final tx = controller.transactions[index];
            return _TransactionCard(tx: tx);
          },
        );
      }),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  const _TransactionCard({required this.tx});

  String _formatTxDate(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }

  (IconData, Color) _getStatusInfo(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PAID:
        return (Icons.check_circle, Colors.green);
      case PaymentStatus.PARTIAL:
        return (Icons.hourglass_top, Colors.orange);
      case PaymentStatus.DEBT:
        return (Icons.error, Colors.red);
      default:
        return (Icons.info, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(tx.paymentStatus);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusInfo.$2.withOpacity(0.1),
          child: Icon(statusInfo.$1, color: statusInfo.$2),
        ),
        title: Text(
          tx.transactionNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${tx.customerName ?? 'Pelanggan Tunai'}\n${_formatTxDate(tx.transactionDate)}",
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.currency.format(tx.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (tx.paymentStatus != PaymentStatus.PAID)
              Text(
                "Sisa: ${Formatters.currency.format(tx.remainingDebt)}",
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        onTap: () {
          // TODO: Detail transaksi (bisa ditambahkan nanti)
        },
      ),
    );
  }
}