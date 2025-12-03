import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Import controller Anda yang sudah ada atau yang baru
// import 'package:kaskredit_1/features/printer/presentation/controllers/enhanced_printer_controller.dart';

class EnhancedPrinterSettingsScreen extends StatelessWidget {
  const EnhancedPrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan controller yang sudah ada atau yang baru
    // final controller = Get.put(EnhancedPrinterController());
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Printer'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Umum'),
              Tab(icon: Icon(Icons.print), text: 'Printer'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.help_outline), text: 'Bantuan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            _buildPrinterTab(),
            _buildHistoryTab(),
            _buildHelpTab(),
          ],
        ),
      ),
    );
  }

  // === TAB 1: GENERAL SETTINGS ===
  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Auto Print Toggle
        Card(
          child: SwitchListTile(
            title: const Text('Cetak Otomatis'),
            subtitle: const Text('Cetak struk langsung setelah transaksi'),
            value: true, // Bind to controller.autoPrint.value
            onChanged: (value) {
              // controller.toggleAutoPrint(value);
            },
            secondary: const Icon(Icons.autorenew),
          ),
        ),

        const SizedBox(height: 16),

        // Print QR Code Toggle
        Card(
          child: SwitchListTile(
            title: const Text('Cetak QR Code'),
            subtitle: const Text('Tambahkan QR code di struk untuk verifikasi'),
            value: false, // Bind to controller.printQRCode.value
            onChanged: (value) {
              // controller.saveSettings(qrCode: value);
            },
            secondary: const Icon(Icons.qr_code),
          ),
        ),

        const SizedBox(height: 16),

        // Paper Size Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.straighten),
                    SizedBox(width: 16),
                    Text(
                      'Ukuran Kertas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('58mm'),
                        value: '58mm',
                        groupValue: '58mm', // Bind to controller.paperSize.value
                        onChanged: (value) {
                          // controller.saveSettings(size: value);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('80mm'),
                        value: '80mm',
                        groupValue: '58mm', // Bind to controller.paperSize.value
                        onChanged: (value) {
                          // controller.saveSettings(size: value);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Number of Copies
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 16),
                    Text(
                      'Jumlah Salinan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        // Decrease copies
                      },
                    ),
                    const Text('1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        // Increase copies
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Reset to 1
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Footer Note
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.note),
                    SizedBox(width: 16),
                    Text(
                      'Catatan Bawah Struk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Terima kasih atas kunjungan Anda',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // Update footer note
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // === TAB 2: PRINTER MANAGEMENT ===
  Widget _buildPrinterTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active Printer Card
        Card(
          color: Colors.green.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Printer Aktif',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Printer Kasir Utama',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '192.168.1.100',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // Edit printer
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Scan for Printers
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Cari Printer di Jaringan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan printer dan HP di jaringan WiFi yang sama',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Scan Printer'),
                    onPressed: () {
                      // Start scan
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Found Printers List
        const Text(
          'Printer Tersimpan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        _PrinterCard(
          name: 'Printer Kasir Utama',
          ip: '192.168.1.100',
          isActive: true,
          onTap: () {},
          onTest: () {},
          onDelete: () {},
        ),

        _PrinterCard(
          name: 'Printer Dapur',
          ip: '192.168.1.101',
          isActive: false,
          onTap: () {},
          onTest: () {},
          onDelete: () {},
        ),

        const SizedBox(height: 16),

        // Add Printer Manually
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Tambah Printer Manual'),
          onPressed: () => _showAddPrinterDialog(),
        ),
      ],
    );
  }

  // === TAB 3: PRINT HISTORY ===
  Widget _buildHistoryTab() {
    return Column(
      children: [
        // Stats Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HistoryStatItem(
                label: 'Total Print',
                value: '248',
                icon: Icons.print,
                color: Colors.blue,
              ),
              _HistoryStatItem(
                label: 'Berhasil',
                value: '245',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _HistoryStatItem(
                label: 'Gagal',
                value: '3',
                icon: Icons.error,
                color: Colors.red,
              ),
            ],
          ),
        ),

        // History List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10, // Replace with actual data
            itemBuilder: (context, index) {
              return _PrintHistoryItem(
                timestamp: DateTime.now().subtract(Duration(hours: index)),
                type: index % 3 == 0 ? 'receipt' : (index % 2 == 0 ? 'payment' : 'report'),
                transactionNumber: 'TRX-20241203-000${index + 1}',
                status: index == 2 ? 'failed' : 'success',
              );
            },
          ),
        ),

        // Clear History Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton.icon(
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Hapus History'),
            onPressed: () {
              // Clear history with confirmation
            },
          ),
        ),
      ],
    );
  }

  // === TAB 4: HELP & TROUBLESHOOTING ===
  Widget _buildHelpTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HelpSection(
          title: 'Cara Menghubungkan Printer',
          items: [
            'Pastikan printer sudah dinyalakan',
            'Hubungkan HP dan printer ke WiFi yang sama',
            'Tekan tombol "Scan Printer" untuk mencari',
            'Pilih printer yang ditemukan',
            'Tekan "Test Koneksi" untuk memastikan',
          ],
        ),

        const SizedBox(height: 16),

        _HelpSection(
          title: 'Troubleshooting',
          items: [
            'Printer tidak terdeteksi? Pastikan printer dan HP di jaringan yang sama',
            'Print gagal? Cek koneksi WiFi dan pastikan printer tidak error',
            'Struk terpotong? Sesuaikan ukuran kertas di pengaturan',
            'Teks tidak jelas? Ganti gulungan kertas dengan yang baru',
          ],
        ),

        const SizedBox(height: 16),

        Card(
          child: ListTile(
            leading: const Icon(Icons.videocam, color: Colors.blue),
            title: const Text('Tutorial Video'),
            subtitle: const Text('Tonton cara setup printer'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open tutorial video
            },
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.green),
            title: const Text('Hubungi Support'),
            subtitle: const Text('Butuh bantuan lebih lanjut?'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Contact support
            },
          ),
        ),

        const SizedBox(height: 24),

        // Recommended Printers
        const Text(
          'Printer Yang Direkomendasikan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        _RecommendedPrinterCard(
          brand: 'Epson',
          model: 'TM-T82',
          features: ['WiFi', 'USB', 'Auto Cutter'],
        ),
        _RecommendedPrinterCard(
          brand: 'Bluetooth',
          model: 'ZJ-5802',
          features: ['Bluetooth', 'Portable', 'Battery'],
        ),
        _RecommendedPrinterCard(
          brand: 'iMin',
          model: 'M2-203',
          features: ['WiFi', 'Android', 'Cloud Print'],
        ),
      ],
    );
  }

  void _showAddPrinterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Printer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nama Printer',
                hintText: 'Contoh: Printer Kasir',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.xxx',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save printer
              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// === HELPER WIDGETS ===

class _PrinterCard extends StatelessWidget {
  final String name;
  final String ip;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onTest;
  final VoidCallback onDelete;

  const _PrinterCard({
    required this.name,
    required this.ip,
    required this.isActive,
    required this.onTap,
    required this.onTest,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.print,
          color: isActive ? Colors.green : Colors.grey,
        ),
        title: Text(name),
        subtitle: Text(ip),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Test',
              onPressed: onTest,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus',
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _HistoryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HistoryStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PrintHistoryItem extends StatelessWidget {
  final DateTime timestamp;
  final String type;
  final String transactionNumber;
  final String status;

  const _PrintHistoryItem({
    required this.timestamp,
    required this.type,
    required this.transactionNumber,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'success';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
        ),
        title: Text(transactionNumber),
        subtitle: Text(_getTypeLabel(type)),
        trailing: Text(
          DateFormat('HH:mm').format(timestamp),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'receipt':
        return 'Struk Transaksi';
      case 'payment':
        return 'Nota Pembayaran';
      case 'report':
        return 'Laporan';
      default:
        return type;
    }
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HelpSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RecommendedPrinterCard extends StatelessWidget {
  final String brand;
  final String model;
  final List<String> features;

  const _RecommendedPrinterCard({
    required this.brand,
    required this.model,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.print, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$brand $model',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: features
                        .map((f) => Chip(
                              label: Text(f),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}