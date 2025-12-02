import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:kaskredit_1/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:kaskredit_1/features/dashboard/presentation/widgets/sales_chart_widget.dart';
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("KasKredit", style: TextStyle(fontSize: 20)),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Get.snackbar(
                'Notifikasi',
                'Fitur notifikasi akan segera tersedia',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Notifikasi',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Pengaturan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Keluar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                authController.signOut();
              } else if (value == 'settings') {
                Get.toNamed(AppRoutes.SETTINGS);
              }
            },
          ),
        ],
      ),
      
      // Floating Action Button untuk Transaksi Kasir
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.CASHIER),
        icon: const Icon(Icons.point_of_sale),
        label: const Text("KASIR"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Obx(() {
        if (controller.isLoading.value && controller.stats.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final safeStats = controller.stats.value ?? const DashboardStats(
          todaySales: 0, todayProfit: 0, todayTransactions: 0, 
          todayNewDebt: 0, totalOutstandingDebt: 0, totalDebtors: 0, 
          lowStockProducts: 0
        );

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✨ BARU: Quick Stats Cards
                  _buildQuickStatsCards(safeStats),
                  
                  const SizedBox(height: 20),

                  // ✨ BARU: Today's Summary
                  _buildTodaySummary(safeStats),

                  const SizedBox(height: 20),

                  // ✨ BARU: Weekly Sales Chart
                  // PERBAIKAN: Menghapus Obx di sini karena 'WeeklySalesChart' tidak mengakses observable secara langsung di builder ini
                  WeeklySalesChart(controller: controller),

                  const SizedBox(height: 20),

                  // ✨ BARU: Alerts & Warnings
                  _buildAlertsSection(safeStats),

                  const SizedBox(height: 20),

                  // Section: Quick Actions
                  _buildQuickActions(),

                  const SizedBox(height: 20),

                  // Section: Menu Grid
                  const Text(
                    "Menu Utama",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuGrid(),

                  const SizedBox(height: 80), // Space untuk FAB
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ✨ BARU: Quick Stats Cards (3 cards horizontal scroll)
  Widget _buildQuickStatsCards(DashboardStats stats) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickStatCard(
            title: "Omzet Hari Ini",
            value: Formatters.currency.format(stats.todaySales),
            icon: Icons.trending_up,
            color: Colors.green,
            subtitle: "${stats.todayTransactions} transaksi",
          ),
          _QuickStatCard(
            title: "Profit Hari Ini",
            value: Formatters.currency.format(stats.todayProfit),
            icon: Icons.attach_money,
            color: Colors.blue,
            subtitle: stats.todayProfit > 0 
                ? "${((stats.todayProfit / stats.todaySales) * 100).toStringAsFixed(0)}% margin"
                : "0% margin",
          ),
          _QuickStatCard(
            title: "Total Piutang",
            value: Formatters.currency.format(stats.totalOutstandingDebt),
            icon: Icons.credit_card,
            color: Colors.orange,
            subtitle: "${stats.totalDebtors} pelanggan",
          ),
        ],
      ),
    );
  }

  // ✨ BARU: Today's Summary Card
  Widget _buildTodaySummary(DashboardStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2C3E50),
              const Color(0xFF3498DB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ringkasan Hari Ini",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${stats.todayTransactions} Trx",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            _SummaryRow(
              label: "Omzet",
              value: Formatters.currency.format(stats.todaySales),
              icon: Icons.shopping_cart,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: "Profit",
              value: Formatters.currency.format(stats.todayProfit),
              icon: Icons.trending_up,
              color: Colors.lightBlueAccent,
            ),
            if (stats.todayNewDebt > 0) ...[
              const SizedBox(height: 12),
              _SummaryRow(
                label: "Kredit Baru",
                value: Formatters.currency.format(stats.todayNewDebt),
                icon: Icons.credit_score,
                color: Colors.orangeAccent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✨ BARU: Alerts & Warnings Section
  Widget _buildAlertsSection(DashboardStats stats) {
    final hasAlerts = stats.lowStockProducts > 0 || stats.totalDebtors > 0;
    
    if (!hasAlerts) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Perhatian",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (stats.lowStockProducts > 0)
          _AlertCard(
            icon: Icons.warning_amber_rounded,
            title: "Stok Menipis",
            message: "${stats.lowStockProducts} produk stok rendah",
            color: Colors.orange,
            onTap: () => Get.toNamed(AppRoutes.PRODUCTS),
          ),
        if (stats.totalDebtors > 0)
          _AlertCard(
            icon: Icons.account_balance_wallet,
            title: "Piutang Aktif",
            message: "${stats.totalDebtors} pelanggan belum lunas",
            color: Colors.red,
            onTap: () => Get.toNamed(AppRoutes.DEBT),
          ),
      ],
    );
  }

  // ✨ IMPROVED: Quick Actions dengan icon lebih besar
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Aksi Cepat",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_shopping_cart,
                label: "Kasir",
                color: Colors.blue,
                onTap: () => Get.toNamed(AppRoutes.CASHIER),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.payment,
                label: "Bayar Utang",
                color: Colors.orange,
                onTap: () => Get.toNamed(AppRoutes.DEBT),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.history,
                label: "Riwayat",
                color: Colors.purple,
                onTap: () => Get.toNamed(AppRoutes.HISTORY),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _MenuCard(
          title: "Produk",
          icon: Icons.inventory_2,
          color: Colors.purple,
          onTap: () => Get.toNamed(AppRoutes.PRODUCTS),
        ),
        _MenuCard(
          title: "Pelanggan",
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => Get.toNamed(AppRoutes.CUSTOMERS),
        ),
        _MenuCard(
          title: "Pengeluaran",
          icon: Icons.payment,
          color: Colors.red,
          onTap: () => Get.toNamed(AppRoutes.EXPENSES),
        ),
        _MenuCard(
          title: "Laporan",
          icon: Icons.assessment,
          color: Colors.green,
          onTap: () => Get.toNamed(AppRoutes.REPORTS),
        ),
        _MenuCard(
          title: "Riwayat Bayar",
          icon: Icons.receipt_long,
          color: Colors.teal,
          onTap: () => Get.toNamed(AppRoutes.PAYMENT_HISTORY),
        ),
        _MenuCard(
          title: "Pengaturan",
          icon: Icons.settings,
          color: Colors.grey,
          onTap: () => Get.toNamed(AppRoutes.SETTINGS),
        ),
      ],
    );
  }
}

// ✨ BARU: Quick Stat Card Widget
class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget untuk Summary Row
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
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

// ✨ BARU: Alert Card Widget
class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final VoidCallback onTap;

  const _AlertCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// ✨ BARU: Quick Action Button Widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Menu Card Widget (improved)
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}