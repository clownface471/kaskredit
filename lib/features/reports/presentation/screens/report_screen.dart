import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:kaskredit_1/features/reports/presentation/providers/report_provider.dart';
import 'package:kaskredit_1/shared/models/sales_report.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  // Helper untuk format Rupiah
  // String _formatCurrency(double amount) {
  //   return 'Rp ${amount.toStringAsFixed(0)}';
  // }

  // Helper untuk memanggil Date Picker
  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, 1, 1); // Izinkan 1 tahun ke belakang
    final lastDate = now;
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      // Set tanggal awal dari provider jika sudah ada
      initialDateRange: ref.read(reportDateRangeProvider),
    );

    if (picked != null) {
      // Simpan rentang tanggal yang dipilih ke provider
      ref.read(reportDateRangeProvider.notifier).state = picked;
      // Langsung generate laporan
      ref.read(salesReportNotifierProvider.notifier).generateReport(
            startDate: picked.start,
            endDate: picked.end,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Tonton" state laporan (AsyncValue) dan rentang tanggal
    final reportState = ref.watch(salesReportNotifierProvider);
    final selectedRange = ref.watch(reportDateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
        actions: [
          // Tombol Kalender
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDateRange(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tampilkan rentang tanggal yang dipilih
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey[200],
            child: Text(
              selectedRange == null
                  ? "Pilih rentang tanggal (klik ikon kalender)"
                  : "Laporan untuk: ${DateFormat('d MMM yyyy').format(selectedRange.start)} - ${DateFormat('d MMM yyyy').format(selectedRange.end)}",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Tampilkan hasil laporan
          Expanded(
            child: reportState.when(
              // Data null berarti state awal (belum generate)
              data: (report) => (report == null)
                  ? const Center(child: Text("Silakan pilih tanggal untuk membuat laporan."))
                  : _buildReportData(context, report),
              
              loading: () => const Center(child: CircularProgressIndicator()),
              
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan data laporan jika sukses
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
                _StatRow(label: "Penjualan Tunai:", value: Formatters.currency.format(report.cashSales)),
                _StatRow(label: "Penjualan Kredit:", value: Formatters.currency.format(report.creditSales)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. Kartu Produk Terlaris
        Text("Produk Terlaris", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (report.topProducts.isEmpty)
          const Text("Tidak ada produk terjual.")
        else
          ...report.topProducts.map(
            (product) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(child: Text(product.quantitySold.toString())),
                title: Text(product.productName),
                subtitle: Text("Omzet: ${Formatters.currency.format(product.totalSales)} | Profit: ${Formatters.currency.format(product.totalProfit)}"),              ),
            ),
          ),
        
        // 3. TODO: Chart Penjualan Harian (bisa ditambahkan nanti)
      ],
    );
  }
}

// Widget helper untuk baris statistik (bisa dipindah ke file shared)
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
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}