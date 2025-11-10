import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Sudah ada
import 'package:go_router/go_router.dart';
import 'package:kaskredit_1/features/auth/data/auth_repository.dart';
// 1. IMPORT PROVIDER BARU KITA
import 'package:kaskredit_1/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

@override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. "TONTON" PROVIDER STATS
    final statsAsync = ref.watch(dashboardStatsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir Mini KREDIT"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 4. PANGGIL FUNGSI SIGNOUT
              ref.read(authRepositoryProvider).signOut();
            },
          )
        ],
      ),
      // 2. Drawer (untuk Profil, dll - Sesuai PDF)
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Toko Kredit"), // Nanti ambil dari user
              accountEmail: Text("email@toko.com"), // Nanti ambil dari user
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                // Nanti panggil signOut()
              },
            ),
          ],
        ),
      ),
      // 3. Tombol Transaksi Besar di Bawah (Sesuai Video)
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Nanti ke halaman kasir
              context.push('/cashier');
            },
            child: const Text(
              "Transaksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      // 4. Body (Grid Menu Utama)
 // 3. GANTI BODY DENGAN .when() UNTUK HANDLING LOADING/ERROR
      body: statsAsync.when(
        // === STATE SUKSES (Data Diterima) ===
        data: (stats) {
          // Tampilkan UI lengkap dengan data
          return _buildDashboardUI(context, stats);
        },
        // === STATE ERROR ===
        error: (err, stack) => Center(
          child: Text("Gagal memuat data: $err"),
        ),
        // === STATE LOADING ===
        loading: () {
          // Tampilkan UI placeholder (skeleton) saat loading
          return _buildDashboardUI(context, null); // Kirim null
        },
      ),
    );
  }

  // --- Widget Baru untuk UI Dashboard ---
  Widget _buildDashboardUI(BuildContext context, DashboardStats? stats) {
    // Jika stats null, kita dalam mode loading, tampilkan placeholder
    final bool isLoading = stats == null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- KARTU STATISTIK HARI INI ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Laporan Hari Ini", style: Theme.of(context).textTheme.titleLarge),
                    const Divider(height: 20),
                    // Gunakan widget _StatRow
                    _StatRow(
                      label: "Total Penjualan:",
                      value: isLoading ? "..." : Formatters.currency.format(stats.todaySales),
                      isLoading: isLoading,
                    ),
                    _StatRow(
                      label: "Total Profit:",
                      value: isLoading ? "..." : Formatters.currency.format(stats.todayProfit),
                      isLoading: isLoading,
                    ),
                    _StatRow(
                      label: "Transaksi:",
                      value: isLoading ? "..." : "${stats.todayTransactions}x",
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // --- KARTU STATISTIK UTANG & STOK ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                     _StatRow(
                      label: "Total Utang Beredar:",
                      value: "Rp ${stats?.totalOutstandingDebt.toStringAsFixed(0) ?? '...'}",
                      valueColor: Colors.red,
                      isLoading: isLoading,
                    ),
                     _StatRow(
                      label: "Jumlah Pelanggan Berutang:",
                      value: "${stats?.totalDebtors ?? '...'} orang",
                      valueColor: Colors.red,
                      isLoading: isLoading,
                    ),
                    const Divider(),
                     _StatRow(
                      label: "Produk Stok Menipis:",
                      value: "${stats?.lowStockProducts ?? '...'} item",
                      valueColor: Colors.orange,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- GRID MENU (Tetap sama) ---
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _MenuCard(
                  title: "Produk",
                  icon: Icons.inventory_2,
                  onTap: () => context.push('/products'),
                ),
                // ... (Semua _MenuCard Anda yang lain) ...
                _MenuCard(
                    title: "Riwayat Bayar",
                    icon: Icons.receipt_long,
                    onTap: () {},
                  ),
                  _MenuCard(
                    title: "Riwayat Transaksi",
                    icon: Icons.history,
                    onTap: () {},
                  ),
                  _MenuCard(
                    title: "Pelanggan",
                    icon: Icons.people,
                    onTap: () => context.push('/customers'),
                  ),
                  _MenuCard(
                    title: "Bayar Utang",
                    icon: Icons.monetization_on,
                    onTap: () => context.push('/debt'),
                  ),
                  _MenuCard(
                    title: "Laporan",
                    icon: Icons.assessment,
                    onTap: () => context.push('/reports'),
                  ),
                  _MenuCard(
                    title: "Pengeluaran",
                    icon: Icons.payment,
                    onTap: () {},
                  ),
                  _MenuCard(
                    title: "Cetak Resi",
                    icon: Icons.print,
                    onTap: () {},
                  ),
                  _MenuCard(
                    title: "Kasir",
                    icon: Icons.person_pin,
                    onTap: () {},
                  ),
                  _MenuCard(
                    title: "Pengaturan",
                    icon: Icons.settings,
                    onTap: () {},
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Helper untuk Kartu Menu (Tetap sama) ---
class _MenuCard extends StatelessWidget {
  // ... (kode _MenuCard Anda sama)
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
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

// --- Widget Helper Baru untuk Baris Statistik ---
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLoading;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          if (isLoading)
            Container( // Skeleton placeholder
              width: 80,
              height: 16,
              color: Colors.grey[300],
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
        ],
      ),
    );
  }
}