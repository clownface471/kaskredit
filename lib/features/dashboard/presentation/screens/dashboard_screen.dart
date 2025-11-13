import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaskredit_1/features/auth/data/auth_repository.dart';
import 'package:kaskredit_1/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';
import 'package:kaskredit_1/core/utils/formatters.dart'; // Kita butuh formatter

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    // Ambil info user (nanti kita pakai)
    // final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      // 1. AppBar (Sesuai Video)
      appBar: AppBar(
        title: const Text("Kasir Mini KREDIT"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          )
        ],
      ),
      
      // 2. Tombol Transaksi (Sesuai Video)
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.grey[800], // Warna gelap
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.push('/cashier'),
            child: const Text(
              "Transaksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),

      // 3. Body (Semua kartu dan grid)
      body: statsAsync.when(
        data: (stats) => _buildDashboardUI(context, stats, false), // false = not loading
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Gagal memuat data: $err"),
          ),
        ),
        loading: () => _buildDashboardUI(context, null, true), // true = loading
      ),
    );
  }

  // --- WIDGET UTAMA UNTUK BODY ---
  Widget _buildDashboardUI(BuildContext context, DashboardStats? stats, bool isLoading) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. KARTU LAPORAN HARI INI (Sesuai Video)
            _LaporanHariIniCard(stats: stats, isLoading: isLoading),
            
            const SizedBox(height: 16),

            // 2. KARTU INFO TOKO (Sesuai Video)
            _InfoTokoCard(
              namaToko: "Toko Kredit Anda", // Nanti pakai: user?.shopName
              alamat: "Jalan Teracota No.17", // Nanti pakai: user?.address
            ),
            
            const SizedBox(height: 16),

            // 3. BOKS JATUH TEMPO (Sesuai Video)
            _JatuhTempoRow(
              jatuhTempoHariIni: 2, // Nanti pakai data
              lewatJatuhTempo: 6, // Nanti pakai data
            ),

            const SizedBox(height: 24),

            // 4. GRID MENU (Sesuai Video)
            GridView.count(
              crossAxisCount: 3, // 3 kolom di HP
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _MenuCard(title: "Produk", icon: Icons.inventory_2, onTap: () => context.push('/products')),
                _MenuCard(title: "Riwayat Bayar", icon: Icons.receipt_long, onTap: () {}),
                _MenuCard(title: "Riwayat Transaksi", icon: Icons.history, onTap: () {}),
                _MenuCard(title: "Pelanggan", icon: Icons.people, onTap: () => context.push('/customers')),
                _MenuCard(title: "Bayar Utang", icon: Icons.monetization_on, onTap: () => context.push('/debt')),
                _MenuCard(title: "Laporan", icon: Icons.assessment, onTap: () => context.push('/reports')),
                _MenuCard(title: "Pengeluaran", icon: Icons.payment, onTap: () {}),
                _MenuCard(title: "Kasir", icon: Icons.person_pin, onTap: () {}),
                _MenuCard(title: "Pengaturan", icon: Icons.settings, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS BARU UNTUK DASHBOARD ---

// 1. KARTU LAPORAN HARI INI
class _LaporanHariIniCard extends StatelessWidget {
  final DashboardStats? stats;
  final bool isLoading;
  const _LaporanHariIniCard({this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[800], // Latar belakang gelap
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Laporan Hari Ini", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            _StatRow(
              label: "Total Penjualan",
              value: isLoading ? "..." : Formatters.currency.format(stats!.todaySales),
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            _StatRow(
              label: "Total Profit",
              value: isLoading ? "..." : Formatters.currency.format(stats!.todayProfit),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// 2. KARTU INFO TOKO
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
            const Icon(Icons.store, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaToko, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(alamat, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

// 3. ROW JATUH TEMPO
class _JatuhTempoRow extends StatelessWidget {
  final int jatuhTempoHariIni;
  final int lewatJatuhTempo;
  const _JatuhTempoRow({required this.jatuhTempoHariIni, required this.lewatJatuhTempo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _JatuhTempoCard(title: "Jatuh Tempo Hari Ini", count: jatuhTempoHariIni, color: Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _JatuhTempoCard(title: "Lewat Jatuh Tempo", count: lewatJatuhTempo, color: Colors.red)),
      ],
    );
  }
}

class _JatuhTempoCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _JatuhTempoCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count.toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
                  Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87), maxLines: 2),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

// 4. KARTU MENU (STYLING DISESUAIKAN)
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// HELPER STAT ROW (DARI LANGKAH SEBELUMNYA, DIPINDAHKAN KE SINI)
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isLoading;

  const _StatRow({
    required this.label,
    required this.value,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: color ?? Colors.white70)),
          if (isLoading)
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4)
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}