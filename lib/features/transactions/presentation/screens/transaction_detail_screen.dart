import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/shared/models/transaction.dart' hide Transaction;
import 'package:kaskredit_1/shared/models/transaction.dart' as tx;
import 'package:kaskredit_1/shared/utils/formatters.dart';
import 'package:kaskredit_1/features/printer/data/printer_service.dart';
import 'package:kaskredit_1/features/printer/presentation/controllers/printer_controller.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx.Transaction transaction = Get.arguments as tx.Transaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        actions: [
          // Tombol Print
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(transaction),
            tooltip: 'Cetak Struk',
          ),
          // Tombol Share (future feature)
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTransaction(transaction),
            tooltip: 'Bagikan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(transaction),
            
            // Customer Info (if exists)
            if (transaction.customerName != null)
              _buildCustomerCard(transaction),
            
            // Items List
            _buildItemsList(transaction),
            
            // Payment Summary
            _buildPaymentSummary(transaction),
            
            // Credit Details (if credit transaction)
            if (transaction.paymentType == tx.PaymentType.CREDIT)
              _buildCreditDetails(transaction),
            
            // Notes (if exists)
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              _buildNotesCard(transaction.notes!),
            
            // Metadata
            _buildMetadata(transaction),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: transaction.paymentStatus != tx.PaymentStatus.PAID
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.snackbar(
                  'Info',
                  'Navigasi ke halaman pembayaran',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text("Bayar"),
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }

  Widget _buildStatusCard(tx.Transaction transaction) {
    final statusColor = _getStatusColor(transaction.paymentStatus);
    final statusText = _getStatusText(transaction.paymentStatus);
    final statusIcon = _getStatusIcon(transaction.paymentStatus);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            transaction.transactionNumber,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Formatters.currency(transaction.totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('d MMMM yyyy, HH:mm', 'id_ID')
                .format(transaction.transactionDate),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(tx.Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          transaction.customerName!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          transaction.paymentType == tx.PaymentType.CREDIT
              ? 'Transaksi Kredit'
              : 'Transaksi Tunai',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to customer detail
        },
      ),
    );
  }

  Widget _buildItemsList(tx.Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item Pembelian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 20),
            ...transaction.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity}x @ ${Formatters.currency(item.sellingPrice)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.currency(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(tx.Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Subtotal',
              value: Formatters.currency(transaction.totalAmount),
            ),
            if (transaction.interestRate > 0) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Bunga (${transaction.interestRate}%)',
                value: Formatters.currency(
                  transaction.totalAmount * (transaction.interestRate / 100),
                ),
                valueColor: Colors.orange,
              ),
            ],
            if (transaction.downPayment > 0) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Down Payment',
                value: '- ${Formatters.currency(transaction.downPayment)}',
                valueColor: Colors.green,
              ),
            ],
            const Divider(height: 24),
            _SummaryRow(
              label: 'Total',
              value: Formatters.currency(transaction.totalAmount),
              isBold: true,
              labelSize: 16,
              valueSize: 18,
            ),
            if (transaction.remainingDebt > 0) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Sisa Utang',
                value: Formatters.currency(transaction.remainingDebt),
                valueColor: Colors.red,
                isBold: true,
              ),
            ],
            const SizedBox(height: 12),
            _PaymentMethodChip(transaction.paymentType),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditDetails(tx.Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Detail Kredit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _InfoRow(
              label: 'Tenor',
              value: '${transaction.tenor} bulan',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Bunga',
              value: '${transaction.interestRate}%',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Cicilan per Bulan',
              value: Formatters.currency(
                transaction.remainingDebt / transaction.tenor,
              ),
            ),
            if (transaction.dueDate != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Jatuh Tempo',
                value: DateFormat('d MMMM yyyy', 'id_ID')
                    .format(transaction.dueDate!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notes,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(tx.Transaction transaction) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Dibuat',
            value: DateFormat('d MMM yyyy, HH:mm', 'id_ID')
                .format(transaction.createdAt),
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: 'Terakhir Update',
            value: DateFormat('d MMM yyyy, HH:mm', 'id_ID')
                .format(transaction.updatedAt),
          ),
          const SizedBox(height: 4),
          _InfoRow(
            label: 'ID Transaksi',
            value: transaction.id ?? '-',
          ),
        ],
      ),
    );
  }

  void _printReceipt(tx.Transaction transaction) async {
    final printerController = Get.find<PrinterController>();
    
    if (printerController.printerIp.value == null) {
      Get.snackbar(
        'Info',
        'Silakan atur printer terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Print',
      'Mencetak struk...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );

    // TODO: Implement actual printing
    // final printerService = PrinterService();
    // final success = await printerService.printReceipt(...)
  }

  void _shareTransaction(tx.Transaction transaction) {
    Get.snackbar(
      'Share',
      'Fitur berbagi akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Color _getStatusColor(tx.PaymentStatus status) {
    switch (status) {
      case tx.PaymentStatus.PAID:
        return Colors.green;
      case tx.PaymentStatus.PARTIAL:
        return Colors.orange;
      case tx.PaymentStatus.DEBT:
        return Colors.red;
    }
  }

  String _getStatusText(tx.PaymentStatus status) {
    switch (status) {
      case tx.PaymentStatus.PAID:
        return 'LUNAS';
      case tx.PaymentStatus.PARTIAL:
        return 'DIBAYAR SEBAGIAN';
      case tx.PaymentStatus.DEBT:
        return 'BELUM DIBAYAR';
    }
  }

  IconData _getStatusIcon(tx.PaymentStatus status) {
    switch (status) {
      case tx.PaymentStatus.PAID:
        return Icons.check_circle;
      case tx.PaymentStatus.PARTIAL:
        return Icons.hourglass_empty;
      case tx.PaymentStatus.DEBT:
        return Icons.pending;
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final double labelSize;
  final double valueSize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.labelSize = 14,
    this.valueSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final tx.PaymentType paymentType;

  const _PaymentMethodChip(this.paymentType);

  @override
  Widget build(BuildContext context) {
    final data = _getPaymentMethodData();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: data.$1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.$1.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.$2, size: 16, color: data.$1),
          const SizedBox(width: 6),
          Text(
            data.$3,
            style: TextStyle(
              color: data.$1,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getPaymentMethodData() {
    switch (paymentType) {
      case tx.PaymentType.CASH:
        return (Colors.green, Icons.payments, 'TUNAI');
      case tx.PaymentType.CREDIT:
        return (Colors.orange, Icons.credit_card, 'KREDIT');
      case tx.PaymentType.TRANSFER:
        return (Colors.blue, Icons.account_balance, 'TRANSFER');
    }
  }
}