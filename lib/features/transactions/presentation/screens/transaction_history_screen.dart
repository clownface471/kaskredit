import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:kaskredit_1/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton provider riwayat transaksi
    final historyAsync = ref.watch(transactionHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
      ),
      body: historyAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text("Belum ada transaksi."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _TransactionCard(tx: tx);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Gagal memuat riwayat: $e")),
      ),
    );
  }
}

// Widget Card untuk setiap item riwayat
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
        trailing: Text(
          Formatters.currency.format(tx.totalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () {
          // TODO: Nanti kita buat halaman detail transaksi
          // context.push('/transactions/${tx.id}');
        },
      ),
    );
  }
}