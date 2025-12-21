// lib/features/dashboard/presentation/screens/dashboard_screen.dart
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
          // ✅ Refresh button with animation
          Obx(() => IconButton(
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: controller.isLoading.value 
                ? null 
                : () => controller.refreshData(),
            tooltip: 'Refresh',
          )),
          
          // ✅ Notification with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNotifications(context, controller),
                tooltip: 'Notifikasi',
              ),
              Obx(() {
                final alerts = _getAlertCount(controller.stats.value);
                if (alerts == 0) return const SizedBox.shrink();
                
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      alerts.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
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
                _confirmLogout(authController);
              } else if (value == 'settings') {
                Get.toNamed(AppRoutes.SETTINGS);
              }
            },
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.CASHIER),
        icon: const Icon(Icons.point_of_sale),
        label: const Text("KASIR"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Obx(() {
        if (controller.isLoading.value && controller.stats.value == null) {
          return _buildLoadingSkeleton();
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
                  // ✅ Quick Stats Cards with Hero Animation
                  _buildQuickStatsCards(safeStats),
                  
                  const SizedBox(height: 20),

                  // ✅ Today's Summary with Gradient
                  _buildTodaySummary(safeStats),

                  const SizedBox(height: 20),

                  // ✅ Weekly Sales Chart
                  WeeklySalesChart(controller: controller),

                  const SizedBox(height: 20),

                  // ✅ Alerts & Warnings
                  _buildAlertsSection(safeStats),

                  const SizedBox(height: 20),

                  // ✅ Quick Actions with Better Icons
                  _buildQuickActions(),

                  const SizedBox(height: 20),

                  // ✅ Menu Grid with Better Layout
                  const Text(
                    "Menu Utama",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuGrid(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ✅ NEW: Loading Skeleton
  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: List.generate(3, (index) => 
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ IMPROVED: Quick Stats Cards with Animation
  Widget _buildQuickStatsCards(DashboardStats stats) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickStatCard(
            title: "Omzet Hari Ini",
            value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(stats.todaySales),
            icon: Icons.trending_up,
            color: Colors.green,
            subtitle: "${stats.todayTransactions} transaksi",
            onTap: () => Get.toNamed(AppRoutes.HISTORY),
          ),
          _QuickStatCard(
            title: "Profit Hari Ini",
            value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(stats.todayProfit),
            icon: Icons.attach_money,
            color: Colors.blue,
            subtitle: stats.todaySales > 0 
                ? "${((stats.todayProfit / stats.todaySales) * 100).toStringAsFixed(0)}% margin"
                : "0% margin",
            onTap: () => Get.toNamed(AppRoutes.REPORTS),
          ),
          _QuickStatCard(
            title: "Total Piutang",
            value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(stats.totalOutstandingDebt),
            icon: Icons.credit_card,
            color: Colors.orange,
            subtitle: "${stats.totalDebtors} pelanggan",
            onTap: () => Get.toNamed(AppRoutes.DEBT),
          ),
        ],
      ),
    );
  }

  // ✅ IMPROVED: Today's Summary with Better Design
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
              value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(stats.todaySales),
              icon: Icons.shopping_cart,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: "Profit",
              value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(stats.todayProfit),
              icon: Icons.trending_up,
              color: Colors.lightBlueAccent,
            ),
            if (stats.todayNewDebt > 0) ...[
              const SizedBox(height: 12),
              _SummaryRow(
                label: "Kredit Baru",
                value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(stats.todayNewDebt),
                icon: Icons.credit_score,
                color: Colors.orangeAccent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ IMPROVED: Alerts Section with Better UX
  Widget _buildAlertsSection(DashboardStats stats) {
    final hasAlerts = stats.lowStockProducts > 0 || stats.totalDebtors > 0;
    
    if (!hasAlerts) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Perhatian",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {}, // View all alerts
              icon: const Icon(Icons.list, size: 16),
              label: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
            ),
          ],
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
            message: "${stats.totalDebtors} pelanggan belum lunas (${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(stats.totalOutstandingDebt)})",
            color: Colors.red,
            onTap: () => Get.toNamed(AppRoutes.DEBT),
          ),
      ],
    );
  }

  // ✅ IMPROVED: Quick Actions with Better Icons
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

  // ✅ NEW: Show notifications bottom sheet
  void _showNotifications(BuildContext context, DashboardController controller) {
    final stats = controller.stats.value;
    if (stats == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            if (stats.lowStockProducts > 0) ...[
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.warning, color: Colors.white),
                ),
                title: const Text('Stok Menipis'),
                subtitle: Text('${stats.lowStockProducts} produk perlu restock'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.PRODUCTS);
                },
              ),
            ],
            if (stats.totalDebtors > 0) ...[
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.credit_card, color: Colors.white),
                ),
                title: const Text('Piutang Aktif'),
                subtitle: Text('${stats.totalDebtors} pelanggan belum lunas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.DEBT);
                },
              ),
            ],
            if (stats.lowStockProducts == 0 && stats.totalDebtors == 0) ...[
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, size: 48, color: Colors.green),
                      SizedBox(height: 8),
                      Text('Tidak ada notifikasi'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Confirm logout
  void _confirmLogout(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  int _getAlertCount(DashboardStats? stats) {
    if (stats == null) return 0;
    int count = 0;
    if (stats.lowStockProducts > 0) count++;
    if (stats.totalDebtors > 0) count++;
    return count;
  }
}

// ✅ IMPROVED: Quick Stat Card with onTap
class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final VoidCallback? onTap;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                if (onTap != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward, color: color, size: 16),
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
      ),
    );
  }
}

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