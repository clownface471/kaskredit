import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/printer/presentation/controllers/printer_controller.dart';

class PrinterSettingsScreen extends StatelessWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrinterController());
    final ipController = TextEditingController(text: controller.printerIp.value);
    final footerController = TextEditingController(text: controller.footerNote.value);

    // Update text controller jika nilai reactive berubah (misal dari hasil scan)
    ever(controller.printerIp, (val) {
      if (val != null && ipController.text != val) {
        ipController.text = val;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => controller.saveSettings(
              ip: ipController.text,
              note: footerController.text,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section: Scan
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cari Printer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Pastikan printer dan HP di jaringan WiFi yang sama.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: controller.isScanning.value 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.search),
                      label: Text(controller.isScanning.value ? 'Mencari...' : 'Scan Printer'),
                      onPressed: controller.isScanning.value ? null : controller.scanPrinters,
                    ),
                  )),

                  Obx(() {
                    if (controller.foundPrinters.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text('Printer Ditemukan:'),
                          ...controller.foundPrinters.map((ip) => ListTile(
                            leading: const Icon(Icons.print, color: Colors.green),
                            title: Text(ip),
                            trailing: TextButton(
                              child: const Text("Pilih"),
                              onPressed: () => controller.saveSettings(ip: ip),
                            ),
                          )),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section: Manual
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP Printer (Manual)',
                      hintText: '192.168.1.xxx',
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
            child: Obx(() => SwitchListTile(
              title: const Text('Cetak Otomatis'),
              subtitle: const Text('Cetak struk langsung setelah transaksi'),
              value: controller.autoPrint.value,
              onChanged: controller.toggleAutoPrint,
            )),
          ),
          const SizedBox(height: 16),

          // Section: Footer
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: footerController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Bawah Struk',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}