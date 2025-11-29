import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/features/reports/presentation/controllers/report_controller.dart';
import 'package:kaskredit_1/shared/models/sales_report.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  Future<void> _selectDateRange(BuildContext context, ReportController controller) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, 1, 1);
    final lastDate = now;
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: controller.selectedRange.value,
    );

    if (picked != null) {
      controller.generateReport(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDateRange(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Rentang Tanggal
          Obx(() {
            final range = controller.selectedRange.value;
            return Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.grey[200],
              child: Text(
                range == null
                    ? "Pilih rentang tanggal (klik ikon kalender)"
                    : "Laporan: ${DateFormat('d MMM yyyy', 'id_ID').format(range.start)} - ${DateFormat('d MMM yyyy', 'id_ID').format(range.end)}",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            );
          }),

          // Content Laporan
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final reportData = controller.report.value;
              if (reportData == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Data laporan belum tersedia"),
                    ],
                  ),
                );
              }

              return _buildReportData(context, reportData);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReportData(BuildContext context, SalesReport report) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. Kartu Ringkasan
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ringkasan Penjualan", style: Theme.of(context).textTheme.titleLarge),
                const Divider(height: 20),
                _StatRow(label: "Total Omzet:", value: Formatters.currency.format(report.totalSales)),
                _StatRow(label: "Total Profit:", value: Formatters.currency.format(report.totalProfit)),
                _StatRow(label: "Jumlah Transaksi:", value: "${report.totalTransactions}x"),
                const Divider(),
                _StatRow(label: "Penjualan Tunai:", value: Formatters.currency.format(report.cashSales)),
                _StatRow(label: "Penjualan Kredit:", value: Formatters.currency.format(report.creditSales)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. Produk Terlaris
        Text("Produk Terlaris (Top 10)", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (report.topProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Tidak ada data produk terjual."),
          )
        else
          ...report.topProducts.map(
            (product) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    "${product.quantitySold}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Profit: ${Formatters.currency.format(product.totalProfit)}"),
                trailing: Text(
                  Formatters.currency.format(product.totalSales),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}