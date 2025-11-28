import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/printer/data/printer_service.dart';
import 'package:kaskredit_1/features/printer/presentation/providers/printer_settings_provider.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/shared/models/transaction_item.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  final _ipController = TextEditingController();
  final _footerController = TextEditingController();
  bool _isScanning = false;
  List<String> _foundPrinters = [];

  @override
  void initState() {
    super.initState();
    // Load saved settings
    Future.microtask(() async {
      final settings = await ref.read(printerSettingsNotifierProvider.future);
      if (settings.printerIp != null) {
        _ipController.text = settings.printerIp!;
      }
      if (settings.footerNote != null) {
        _footerController.text = settings.footerNote!;
      }
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _scanPrinters() async {
    setState(() {
      _isScanning = true;
      _foundPrinters = [];
    });

    try {
      final printers = await ref.read(printerServiceProvider).scanPrinters();
      setState(() {
        _foundPrinters = printers;
        _isScanning = false;
      });

      if (printers.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ditemukan printer di jaringan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final ip = _ipController.text.trim();
    final footer = _footerController.text.trim();

    if (ip.isNotEmpty) {
      await ref.read(printerSettingsNotifierProvider.notifier).setPrinterIp(ip);
    }

    if (footer.isNotEmpty) {
      await ref.read(printerSettingsNotifierProvider.notifier).setFooterNote(footer);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan printer disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testPrint() async {
    final settings = await ref.read(printerSettingsNotifierProvider.future);
    
    if (settings.printerIp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan atur IP printer terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // Coba print test
    final service = ref.read(printerServiceProvider);
    
    // Buat dummy transaction untuk test
    final testTransaction = Transaction(
      userId: 'test',
      transactionNumber: 'TEST-001',
      items: [
        TransactionItem(
          productId: '1',
          productName: 'Test Product',
          quantity: 1,
          sellingPrice: 10000,
          capitalPrice: 8000,
          subtotal: 10000,
        ),
      ],
      totalAmount: 10000,
      totalProfit: 2000,
      paymentStatus: PaymentStatus.PAID,
      paymentType: PaymentType.CASH,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await service.printReceipt(
      printerIp: settings.printerIp!,
      transaction: testTransaction,
      shopName: 'TEST PRINT',
      footerNote: settings.footerNote,
    );

    // Close loading
    if (mounted) Navigator.of(context).pop();

    // Show result
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Test print berhasil!' : 'Test print gagal'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(printerSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Section: Scan Printer
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cari Printer',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pastikan printer thermal sudah terhubung ke jaringan WiFi yang sama',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isScanning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isScanning ? 'Mencari...' : 'Scan Printer'),
                        onPressed: _isScanning ? null : _scanPrinters,
                      ),
                    ),
                    if (_foundPrinters.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Printer ditemukan:'),
                      const SizedBox(height: 8),
                      ..._foundPrinters.map(
                        (ip) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.print, color: Colors.green),
                          title: Text(ip),
                          trailing: TextButton(
                            child: const Text('Pilih'),
                            onPressed: () {
                              _ipController.text = ip;
                              ref
                                  .read(printerSettingsNotifierProvider.notifier)
                                  .setPrinterIp(ip);
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section: Manual IP
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IP Printer (Manual)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'Contoh: 192.168.1.100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wifi),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section: Auto Print
            Card(
              child: SwitchListTile(
                title: const Text('Cetak Otomatis'),
                subtitle: const Text('Cetak struk otomatis setelah transaksi selesai'),
                value: settings.autoPrint,
                onChanged: (value) {
                  ref
                      .read(printerSettingsNotifierProvider.notifier)
                      .setAutoPrint(value);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Section: Footer Note
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Footer Struk',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _footerController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Footer',
                        hintText: 'Misal: Terima kasih atas kunjungan Anda',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Test Print Button
            if (settings.printerIp != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Test Print'),
                  onPressed: _testPrint,
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}