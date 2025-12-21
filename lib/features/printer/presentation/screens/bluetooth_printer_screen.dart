// lib/features/printer/presentation/screens/bluetooth_printer_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:kaskredit_1/features/printer/presentation/controllers/bluetooth_printer_controller.dart';

class BluetoothPrinterScreen extends StatelessWidget {
  const BluetoothPrinterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BluetoothPrinterController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Printer Bluetooth'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bluetooth), text: 'Printer'),
              Tab(icon: Icon(Icons.settings), text: 'Pengaturan'),
              Tab(icon: Icon(Icons.help_outline), text: 'Bantuan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrinterTab(controller),
            _buildSettingsTab(controller),
            _buildHelpTab(),
          ],
        ),
      ),
    );
  }

  // === TAB 1: PRINTER MANAGEMENT ===
  Widget _buildPrinterTab(BluetoothPrinterController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bluetooth Status Card
        Obx(() => _buildBluetoothStatusCard(controller)),
        
        const SizedBox(height: 16),
        
        // Connected Printer Card (if connected)
        Obx(() {
          if (controller.isConnected.value && controller.selectedDevice.value != null) {
            return _buildConnectedPrinterCard(controller);
          }
          return const SizedBox.shrink();
        }),
        
        const SizedBox(height: 16),
        
        // Paired Devices Section
        const Text(
          'Printer yang Dipasangkan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Printer yang sudah di-pairing dengan HP ini',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        
        Obx(() {
          if (controller.pairedDevices.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum ada printer yang dipasangkan',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Muat Ulang'),
                      onPressed: controller.getPairedDevices,
                    ),
                  ],
                ),
              ),
            );
          }
          
          return Column(
            children: controller.pairedDevices.map((device) {
              final isSelected = controller.selectedDevice.value?.address == device.address;
              final isConnected = controller.isConnected.value && isSelected;
              
              return Card(
                elevation: isConnected ? 4 : 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isConnected
                      ? const BorderSide(color: Colors.green, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.print,
                      color: isConnected ? Colors.green : Colors.blue,
                    ),
                  ),
                  title: Text(
                    device.name ?? 'Printer Bluetooth',
                    style: TextStyle(
                      fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    device.address,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isConnected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.print, color: Colors.green),
                              onPressed: controller.testConnection,
                              tooltip: 'Test Print',
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: controller.disconnect,
                              tooltip: 'Putuskan',
                            ),
                          ],
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => controller.connectDevice(device),
                ),
              );
            }).toList(),
          );
        }),
        
        const SizedBox(height: 24),
        
        // Scan New Devices Section
        const Text(
          'Cari Printer Baru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.blue.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.bluetooth_searching, size: 48, color: Colors.blue),
                const SizedBox(height: 12),
                const Text(
                  'Pastikan printer Bluetooth sudah dalam mode pairing',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: controller.isScanning.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      controller.isScanning.value
                          ? 'Mencari...'
                          : 'Mulai Scan',
                    ),
                    onPressed: controller.isScanning.value
                        ? null
                        : controller.scanDevices,
                  ),
                )),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Scanned Devices List
        Obx(() {
          if (controller.availableDevices.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Printer Ditemukan (${controller.availableDevices.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...controller.availableDevices.map((device) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.bluetooth, color: Colors.blue),
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.address),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => controller.connectDevice(device),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBluetoothStatusCard(BluetoothPrinterController controller) {
    return Card(
      color: controller.bluetoothEnabled.value
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              controller.bluetoothEnabled.value
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              size: 32,
              color: controller.bluetoothEnabled.value ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.bluetoothEnabled.value
                        ? 'Bluetooth Aktif'
                        : 'Bluetooth Nonaktif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: controller.bluetoothEnabled.value
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Text(
                    controller.connectionStatus.value,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!controller.bluetoothEnabled.value)
              ElevatedButton(
                onPressed: controller.requestEnableBluetooth,
                child: const Text('Aktifkan'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedPrinterCard(BluetoothPrinterController controller) {
    final device = controller.selectedDevice.value!;
    
    return Card(
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
                  child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Printer Terhubung',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        device.name ?? 'Printer Bluetooth',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        device.address,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Test Print'),
                    onPressed: controller.testConnection,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Putuskan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: controller.disconnect,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === TAB 2: SETTINGS ===
  Widget _buildSettingsTab(BluetoothPrinterController controller) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Auto Print Toggle
        Card(
          child: Obx(() => SwitchListTile(
            title: const Text('Cetak Otomatis'),
            subtitle: const Text('Cetak struk langsung setelah transaksi'),
            value: controller.autoPrint.value,
            onChanged: controller.toggleAutoPrint,
            secondary: const Icon(Icons.autorenew),
          )),
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
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('58mm'),
                        value: '58mm',
                        groupValue: controller.paperSize.value,
                        onChanged: (value) => controller.updatePaperSize(value!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('80mm'),
                        value: '80mm',
                        groupValue: controller.paperSize.value,
                        onChanged: (value) => controller.updatePaperSize(value!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
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
                Obx(() => TextField(
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Terima kasih atas kunjungan Anda',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(text: controller.footerNote.value)
                    ..selection = TextSelection.collapsed(
                      offset: controller.footerNote.value.length,
                    ),
                  onChanged: controller.updateFooterNote,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // === TAB 3: HELP ===
  Widget _buildHelpTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HelpSection(
          title: 'Cara Menghubungkan Printer',
          icon: Icons.bluetooth,
          steps: [
            'Nyalakan printer Bluetooth dan pastikan dalam mode pairing',
            'Buka Pengaturan Bluetooth di HP Anda',
            'Cari dan pairing printer dengan HP',
            'Kembali ke aplikasi ini',
            'Pilih printer dari daftar "Printer yang Dipasangkan"',
            'Tekan "Test Print" untuk memastikan koneksi',
          ],
        ),
        
        const SizedBox(height: 16),
        
        _HelpSection(
          title: 'Troubleshooting',
          icon: Icons.help_outline,
          steps: [
            'Printer tidak terdeteksi? Pastikan printer sudah di-pairing di pengaturan Bluetooth HP',
            'Print gagal? Cek koneksi dan pastikan printer tidak sedang digunakan aplikasi lain',
            'Struk terpotong? Sesuaikan ukuran kertas di pengaturan (58mm/80mm)',
            'Teks tidak jelas? Ganti gulungan kertas thermal dengan yang baru',
          ],
        ),
        
        const SizedBox(height: 16),
        
        Card(
          color: Colors.blue.withOpacity(0.05),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Text(
                      'Tips Penting',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('• Gunakan printer thermal yang support ESC/POS command'),
                Text('• Jarak maksimal Bluetooth: 10 meter'),
                Text('• Pastikan baterai printer cukup saat mencetak'),
                Text('• Beberapa printer butuh waktu warming up 5-10 detik'),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text(
          'Printer Yang Direkomendasikan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        _PrinterRecommendation(
          brand: 'Zjiang',
          model: 'ZJ-5802',
          features: ['58mm', 'Bluetooth', 'Portable', 'Battery'],
          price: '±350rb',
        ),
        _PrinterRecommendation(
          brand: 'Goojprt',
          model: 'PT-210',
          features: ['58mm', 'Bluetooth', 'Rechargeable'],
          price: '±300rb',
        ),
        _PrinterRecommendation(
          brand: 'Eppos',
          model: 'RPP02N',
          features: ['58mm', 'Bluetooth', 'Battery'],
          price: '±250rb',
        ),
      ],
    );
  }
}

// Helper Widgets
class _HelpSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> steps;

  const _HelpSection({
    required this.title,
    required this.icon,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
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

class _PrinterRecommendation extends StatelessWidget {
  final String brand;
  final String model;
  final List<String> features;
  final String price;

  const _PrinterRecommendation({
    required this.brand,
    required this.model,
    required this.features,
    required this.price,
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
                              label: Text(f, style: const TextStyle(fontSize: 10)),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}