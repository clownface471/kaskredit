// lib/features/printer/presentation/screens/printer_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/printer/presentation/controllers/unified_printer_controller.dart';
import 'package:kaskredit_1/core/services/unified_printer_service.dart';

class PrinterSelectionScreen extends StatelessWidget {
  const PrinterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnifiedPrinterController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Printer'),
        actions: [
          Obx(() => IconButton(
            icon: controller.isScanning.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: controller.isScanning.value 
                ? null 
                : controller.scanDevices,
            tooltip: 'Scan Printer',
          )),
        ],
      ),
      body: Column(
        children: [
          // Current Connection Status
          Obx(() {
            final device = controller.selectedDevice.value;
            if (device == null) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Belum ada printer terhubung'),
                    ),
                  ],
                ),
              );
            }
            
            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDeviceIcon(device.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terhubung',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          device.id,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.green),
                        onPressed: controller.testConnection,
                        tooltip: 'Test Print',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: controller.disconnect,
                        tooltip: 'Disconnect',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          
          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.blue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tekan "Refresh" untuk mencari printer WiFi, Bluetooth, atau USB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Device List
          Expanded(
            child: Obx(() {
              if (controller.isScanning.value && controller.availableDevices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Mencari printer...'),
                    ],
                  ),
                );
              }
              
              if (controller.availableDevices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_disabled,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada printer ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pastikan printer sudah dinyalakan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Cari Printer'),
                        onPressed: controller.scanDevices,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.availableDevices.length,
                itemBuilder: (context, index) {
                  final device = controller.availableDevices[index];
                  final isSelected = controller.selectedDevice.value?.id == device.id;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? const BorderSide(color: Colors.green, width: 2)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getDeviceColor(device.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getDeviceIcon(device.type),
                          color: _getDeviceColor(device.type),
                        ),
                      ),
                      title: Text(
                        device.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        device.id,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.chevron_right),
                      onTap: () => controller.connectDevice(device),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  IconData _getDeviceIcon(PrinterConnectionType type) {
    switch (type) {
      case PrinterConnectionType.wifi:
        return Icons.wifi;
      case PrinterConnectionType.bluetooth:
        return Icons.bluetooth;
      case PrinterConnectionType.usb:
        return Icons.usb;
    }
  }
  
  Color _getDeviceColor(PrinterConnectionType type) {
    switch (type) {
      case PrinterConnectionType.wifi:
        return Colors.blue;
      case PrinterConnectionType.bluetooth:
        return Colors.indigo;
      case PrinterConnectionType.usb:
        return Colors.green;
    }
  }
}