import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/auth/data/auth_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

Widget build(BuildContext context, WidgetRef ref){
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
              // context.push('/cashier');
            },
            child: const Text(
              "Transaksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      // 4. Body (Grid Menu Utama)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Placeholder untuk Laporan & Info Toko
              // (Nanti kita isi ini dengan data real)
              const Card(
                child: ListTile(
                  title: Text("Laporan Hari Ini"),
                  subtitle: Text("Total Penjualan: Rp 0"),
                ),
              ),
              const SizedBox(height: 16),

              // GRID MENU (Sesuai saran Anda: 3 kolom)
              GridView.count(
                crossAxisCount: 3, // 3 Kolom untuk HP
                shrinkWrap: true, // Agar GridView tidak scroll
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  // Menu-menu ini berdasarkan screenshot
                  _MenuCard(
                    title: "Produk",
                    icon: Icons.inventory_2,
                    onTap: () => context.push('/products'),
                  ),
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
                    title: "Pengeluaran",
                    icon: Icons.payment,
                    onTap: () {},
                  ),
                  _MenuCard(
                    title: "Laporan",
                    icon: Icons.assessment,
                    onTap: () => context.push('/reports'),
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
      ),
    );
  }
}

// Widget helper untuk kartu menu
class _MenuCard extends StatelessWidget {
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