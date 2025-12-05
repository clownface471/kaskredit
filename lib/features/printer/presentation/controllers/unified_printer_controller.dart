// lib/features/printer/presentation/controllers/unified_printer_controller.dart
import 'package:flutter/material.dart'; // TAMBAHAN
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaskredit_1/core/services/unified_printer_service.dart';
import 'package:kaskredit_1/features/printer/data/printer_service.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class UnifiedPrinterController extends GetxController {
  final UnifiedPrinterService _service = UnifiedPrinterService();
  
  // State
  final RxList<PrinterDeviceInfo> availableDevices = <PrinterDeviceInfo>[].obs;
  final Rxn<PrinterDeviceInfo> selectedDevice = Rxn<PrinterDeviceInfo>();
  final RxBool isScanning = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isPrinting = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  
  // Settings
  final RxString footerNote = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadSavedDevice();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    footerNote.value = prefs.getString('footer_note') ?? 
        'Terima kasih atas kunjungan Anda';
  }
  
  /// Scan All Printers (WiFi, Bluetooth, USB)
  Future<void> scanDevices() async {
    isScanning.value = true;
    availableDevices.clear();
    
    try {
      final hasPermission = await _service.requestPermissions();
      if (!hasPermission) {
        Get.snackbar(
          'Izin Diperlukan',
          'Aplikasi memerlukan izin Bluetooth dan Lokasi untuk mencari printer',
          snackPosition: SnackPosition.BOTTOM,
        );
        isScanning.value = false;
        return;
      }
      
      final devices = await _service.scanAllPrinters();
      availableDevices.value = devices;
      
      if (devices.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada printer ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Berhasil',
          'Ditemukan ${devices.length} printer',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal scan printer: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }
  
  /// Connect to Selected Printer
  Future<void> connectDevice(PrinterDeviceInfo device) async {
    connectionStatus.value = 'Connecting...';
    
    try {
      final result = await _service.connect(device);
      
      if (result == PrintResult.success) {
        selectedDevice.value = device;
        isConnected.value = true;
        connectionStatus.value = 'Connected';
        
        await _saveDevice(device);
        
        Get.snackbar(
          'Berhasil',
          'Terhubung ke ${device.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        );
      } else {
        connectionStatus.value = 'Connection Failed';
        Get.snackbar(
          'Gagal',
          _service.getErrorMessage(result),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        );
      }
    } catch (e) {
      connectionStatus.value = 'Error';
      Get.snackbar(
        'Error',
        'Gagal terhubung: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Disconnect Printer
  Future<void> disconnect() async {
    await _service.disconnect();
    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
    
    Get.snackbar(
      'Info',
      'Printer terputus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  /// Test Connection
  Future<void> testConnection() async {
    if (!isConnected.value) {
      Get.snackbar(
        'Error',
        'Printer belum terhubung',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    
    try {
      final result = await _service.testConnection();
      Get.back(); // Close loading
      
      if (result == PrintResult.success) {
        Get.snackbar(
          'Berhasil',
          'Test print berhasil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        );
      } else {
        Get.snackbar(
          'Gagal',
          _service.getErrorMessage(result),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Test print gagal: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Print Receipt
  Future<void> printReceipt({
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
  }) async {
    if (!isConnected.value) {
      Get.snackbar(
        'Error',
        'Printer belum terhubung',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    isPrinting.value = true;
    
    try {
      final result = await _service.printReceipt(
        transaction: transaction,
        shopName: shopName,
        shopAddress: shopAddress,
        shopPhone: shopPhone,
        footerNote: footerNote.value,
      );
      
      if (result == PrintResult.success) {
        Get.snackbar(
          'Berhasil',
          'Struk berhasil dicetak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        );
      } else {
        Get.snackbar(
          'Gagal',
          _service.getErrorMessage(result),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal print: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPrinting.value = false;
    }
  }
  
  /// Save Device to Storage
  Future<void> _saveDevice(PrinterDeviceInfo device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_type', device.type.toString());
    await prefs.setString('printer_id', device.id);
    await prefs.setString('printer_name', device.name);
  }
  
  /// Load Saved Device
  Future<void> _loadSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final printerType = prefs.getString('printer_type');
    final printerId = prefs.getString('printer_id');
    final printerName = prefs.getString('printer_name');
    
    if (printerType != null && printerId != null && printerName != null) {
      // Try to auto-reconnect
      // This is optional - user can manually connect
    }
  }
  
  /// Update Footer Note
  Future<void> updateFooterNote(String note) async {
    footerNote.value = note;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('footer_note', note);
  }
}