import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';
import 'package:kaskredit_1/features/transactions/presentation/controllers/transaction_history_controller.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionHistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        actions: [
          // Filter by payment status
          PopupMenuButton<PaymentStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              // TODO: Implement filter
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 12),
                    Text('Semua Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: PaymentStatus.PAID,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Lunas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: PaymentStatus.PARTIAL,
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Cicilan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: PaymentStatus.DEBT,
                child: Row(
                  children: [
                    Icon(Icons.error, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Belum Lunas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Stats
          Obx(() {
            if (controller.transactions.isEmpty) {
              return const SizedBox.shrink();
            }

            final totalSales = controller.transactions.fold<double>(
              0,
              (sum, tx) => sum + tx.totalAmount,
            );
            final totalProfit = controller.transactions.fold<double>(
              0,
              (sum, tx) => sum + tx.totalProfit,
            );
            final unpaidCount = controller.transactions
                .where((tx) => tx.paymentStatus != PaymentStatus.PAID)
                .length;

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'Total Omzet',
                          value: Formatters.compact(totalSales),
                          icon: Icons.trending_up,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Total Profit',
                          value: Formatters.compact(totalProfit),
                          icon: Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                  if (unpaidCount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$unpaidCount transaksi belum lunas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Transaction List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.transactions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada transaksi",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Transaksi akan muncul di sini",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // Refresh by re-binding stream
                  controller.onInit();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = controller.transactions[index];
                    return _TransactionCard(tx: tx);
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  const _TransactionCard({required this.tx});

  String _formatTxDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Hari ini, ${DateFormat('HH:mm').format(date)}';
    } else if (txDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('d MMM yyyy, HH:mm').format(date);
    }
  }

  (IconData, Color) _getStatusInfo(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PAID:
        return (Icons.check_circle, Colors.green);
      case PaymentStatus.PARTIAL:
        return (Icons.hourglass_top, Colors.orange);
      case PaymentStatus.DEBT:
        return (Icons.error, Colors.red);
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PAID:
        return 'Lunas';
      case PaymentStatus.PARTIAL:
        return 'Cicilan';
      case PaymentStatus.DEBT:
        return 'Belum Lunas';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(tx.paymentStatus);
    final statusColor = statusInfo.$2;
    final statusIcon = statusInfo.$1;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: tx.paymentStatus != PaymentStatus.PAID
            ? BorderSide(color: statusColor.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(
            AppRoutes.TRANSACTION_DETAIL,
            arguments: tx,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  
                  // Transaction Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.transactionNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tx.customerName ?? 'Pelanggan Umum',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency(tx.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${tx.items.length} item',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatTxDate(tx.transactionDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusText(tx.paymentStatus),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Remaining debt indicator
              if (tx.remainingDebt > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sisa utang: ${Formatters.currency(tx.remainingDebt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}