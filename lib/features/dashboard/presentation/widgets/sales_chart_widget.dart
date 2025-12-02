import 'package:flutter/material.dart';
import 'package:kaskredit_1/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';
import 'package:intl/intl.dart';

class WeeklySalesChart extends StatelessWidget {
  final DashboardController controller;
  
  const WeeklySalesChart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Penjualan 7 Hari Terakhir",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total: ${Formatters.currency(controller.weekTotalSales)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        "${controller.weekTotalSales > 0 ? ((controller.weekTotalProfit / controller.weekTotalSales) * 100).toStringAsFixed(0) : 0}%",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Chart
            if (controller.isLoadingChart.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.weeklyData.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "Belum ada data penjualan",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              _buildChart(context),
            
            const SizedBox(height: 16),
            
            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final data = controller.weeklyData;
    final maxValue = controller.maxSalesValue;
    
    // Jika semua nilai 0, tampilkan pesan
    if (maxValue == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            "Belum ada transaksi minggu ini",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: data.map((dayData) {
          final heightRatio = dayData.sales / maxValue;
          // PERBAIKAN: Kurangi multiplier tinggi bar dari 160 ke 140
          // agar ada ruang cukup untuk teks label di atas dan bawah (mencegah overflow)
          final barHeight = heightRatio * 140; 
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value on top
                  if (dayData.sales > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _formatCompactCurrency(dayData.sales),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        maxLines: 1, // Pastikan 1 baris
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Bar
                  GestureDetector(
                    onTap: () => _showDayDetail(context, dayData),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      // Pastikan tinggi minimal bar terlihat jika ada sales
                      height: barHeight < 20 && dayData.sales > 0 ? 20 : barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        boxShadow: dayData.sales > 0 ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Day label
                  Text(
                    _formatDayLabel(dayData.date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _isToday(dayData.date) 
                          ? Colors.blue 
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LegendItem(
          color: Colors.blue,
          label: "Omzet",
        ),
        const SizedBox(width: 20),
        const _LegendItem(
          color: Colors.green,
          label: "Profit",
        ),
      ],
    );
  }

  void _showDayDetail(BuildContext context, DailySalesData dayData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dayData.date),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(
              label: "Omzet",
              value: Formatters.currency(dayData.sales),
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: "Profit",
              value: Formatters.currency(dayData.profit),
              color: Colors.green,
            ),
            if (dayData.sales > 0) ...[
              const Divider(height: 24),
              _DetailRow(
                label: "Margin",
                value: "${((dayData.profit / dayData.sales) * 100).toStringAsFixed(1)}%",
                color: Colors.orange,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return "Hari ini";
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return "Kemarin";
    } else {
      return DateFormat('EEE', 'id_ID').format(date);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}Jt";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}Rb";
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}