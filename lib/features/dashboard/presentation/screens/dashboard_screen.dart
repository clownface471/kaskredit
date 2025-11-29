import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:kaskredit_1/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject DashboardController
    final controller = Get.put(DashboardController());
    // Cari AuthController yang sudah ada (dari InitialBinding)
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("KasKredit Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      
      // Bottom Navigation Bar manual untuk akses cepat ke Kasir
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.grey[800], 
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.toNamed(AppRoutes.CASHIER),
            child: const Text(
              "TRANSAKSI KASIR",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),

      body: Obx(() {
        // Tampilan Loading
        if (controller.isLoading.value && controller.stats.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Gunakan stats yang ada, atau data kosong default jika null/error
        final safeStats = controller.stats.value ?? const DashboardStats(
          todaySales: 0, todayProfit: 0, todayTransactions: 0, 
          todayNewDebt: 0, totalOutstandingDebt: 0, totalDebtors: 0, lowStockProducts: 0
        );

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 1. Kartu Laporan Hari Ini
                  _LaporanHariIniCard(stats: safeStats),

                  const SizedBox(height: 16),

                  // 2. Info Toko (Hardcoded sementara / bisa ambil dari AuthController user)
                  const _InfoTokoCard(
                    namaToko: "Toko Kredit Anda", 
                    alamat: "Selamat Datang!", 
                  ),

                  const SizedBox(height: 16),

                  // 3. Jatuh Tempo (Dummy Data sesuai kode lama)
                  const _JatuhTempoRow(
                    jatuhTempoHariIni: 0,
                    lewatJatuhTempo: 0,
                  ),

                  const SizedBox(height: 24),

                  // 4. Menu Grid
                  GridView.count(
                    crossAxisCount: 3, 
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _MenuCard(title: "Produk", icon: Icons.inventory_2, onTap: () => Get.toNamed(AppRoutes.PRODUCTS)),
                      _MenuCard(title: "Pelanggan", icon: Icons.people, onTap: () => Get.toNamed(AppRoutes.CUSTOMERS)),
                      _MenuCard(title: "Kasir", icon: Icons.point_of_sale, onTap: () => Get.toNamed(AppRoutes.CASHIER)), 
                      
                      _MenuCard(title: "Bayar Utang", icon: Icons.monetization_on, onTap: () => Get.toNamed(AppRoutes.DEBT)),
                      _MenuCard(title: "Pengeluaran", icon: Icons.payment, onTap: () => Get.toNamed(AppRoutes.EXPENSES)),
                      _MenuCard(title: "Laporan", icon: Icons.assessment, onTap: () => Get.toNamed(AppRoutes.REPORTS)),
                      
                      _MenuCard(title: "Riwayat Trx", icon: Icons.history, onTap: () => Get.toNamed(AppRoutes.HISTORY)),
                      _MenuCard(title: "Riwayat Bayar", icon: Icons.receipt_long, onTap: () => Get.toNamed(AppRoutes.PAYMENT_HISTORY)),
                      _MenuCard(title: "Pengaturan", icon: Icons.settings, onTap: () => Get.toNamed(AppRoutes.SETTINGS)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// --- WIDGET HELPER (LOKAL) ---

class _LaporanHariIniCard extends StatelessWidget {
  final DashboardStats stats;
  const _LaporanHariIniCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFF2C3E50), // Warna gelap elegan
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ringkasan Hari Ini", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                Text("${stats.todayTransactions} Trx", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            _StatRow(label: "Omzet", value: Formatters.currency.format(stats.todaySales), color: Colors.greenAccent),
            const SizedBox(height: 4),
            _StatRow(label: "Profit", value: Formatters.currency.format(stats.todayProfit), color: Colors.lightBlueAccent),
            const SizedBox(height: 4),
            if (stats.todayNewDebt > 0)
              _StatRow(label: "Kredit Baru", value: Formatters.currency.format(stats.todayNewDebt), color: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatRow({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
        ],
      ),
    );
  }
}

class _InfoTokoCard extends StatelessWidget {
  final String namaToko;
  final String alamat;
  const _InfoTokoCard({required this.namaToko, required this.alamat});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.store, size: 32, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(namaToko, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(alamat, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ])),
          ],
        ),
      ),
    );
  }
}

class _JatuhTempoRow extends StatelessWidget {
  final int jatuhTempoHariIni;
  final int lewatJatuhTempo;
  const _JatuhTempoRow({required this.jatuhTempoHariIni, required this.lewatJatuhTempo});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _JatuhTempoCard(title: "Jatuh Tempo\nHari Ini", count: jatuhTempoHariIni, color: Colors.orange)),
      const SizedBox(width: 16),
      Expanded(child: _JatuhTempoCard(title: "Lewat\nJatuh Tempo", count: lewatJatuhTempo, color: Colors.red)),
    ]);
  }
}

class _JatuhTempoCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _JatuhTempoCard({required this.title, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(count.toString(), style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ]),
          Icon(Icons.calendar_today, size: 20, color: color),
        ]
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuCard({required this.title, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}