import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil transaction dari arguments
    final Transaction transaction = Get.arguments as Transaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // TODO: Implement print
              Get.snackbar("Info", "Fitur print akan segera hadir");
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.transactionNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      _StatusChip(status: transaction.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d MMMM yyyy, HH:mm', 'id_ID')
                        .format(transaction.transactionDate),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (transaction.customerName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          transaction.customerName!,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Items Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Item Pembelian",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const Divider(height: 20),
                  ...transaction.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
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
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${item.quantity} × ${Formatters.currency.format(item.sellingPrice)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600]
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          Formatters.currency.format(item.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        Formatters.currency.format(transaction.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Pembayaran",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const Divider(height: 20),
                  _InfoRow(
                    label: "Tipe Pembayaran",
                    value: _getPaymentTypeText(transaction.paymentType),
                  ),
                  
                  if (transaction.paymentType == PaymentType.CREDIT) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: "DP",
                      value: Formatters.currency.format(transaction.downPayment),
                    ),
                    _InfoRow(
                      label: "Bunga",
                      value: "${transaction.interestRate}%",
                    ),
                    _InfoRow(
                      label: "Tenor",
                      value: "${transaction.tenor} bulan",
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      label: "Total + Bunga",
                      value: Formatters.currency.format(
                        transaction.totalAmount + 
                        (transaction.totalAmount * transaction.interestRate / 100)
                      ),
                    ),
                    _InfoRow(
                      label: "Sudah Dibayar",
                      value: Formatters.currency.format(transaction.paidAmount),
                      valueColor: Colors.green,
                    ),
                    _InfoRow(
                      label: "Sisa Utang",
                      value: Formatters.currency.format(transaction.remainingDebt),
                      valueColor: Colors.red,
                      isBold: true,
                    ),
                    if (transaction.tenor > 0) ...[
                      const SizedBox(height: 4),
                      _InfoRow(
                        label: "Cicilan/Bulan",
                        value: Formatters.currency.format(
                          transaction.remainingDebt / transaction.tenor
                        ),
                        valueColor: Colors.orange,
                      ),
                    ],
                  ],

                  if (transaction.notes != null && 
                      transaction.notes!.isNotEmpty) ...[
                    const Divider(height: 20),
                    const Text(
                      "Catatan:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.notes!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Profit Info (untuk internal)
          Card(
            color: Colors.green.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Profit Kotor",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Formatters.currency.format(transaction.totalProfit),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentTypeText(PaymentType type) {
    switch (type) {
      case PaymentType.CASH:
        return "Tunai";
      case PaymentType.CREDIT:
        return "Kredit";
      case PaymentType.TRANSFER:
        return "Transfer";
    }
  }
}

class _StatusChip extends StatelessWidget {
  final PaymentStatus status;
  
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case PaymentStatus.PAID:
        color = Colors.green;
        text = "LUNAS";
        break;
      case PaymentStatus.PARTIAL:
        color = Colors.orange;
        text = "CICILAN";
        break;
      case PaymentStatus.DEBT:
        color = Colors.red;
        text = "UTANG";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}