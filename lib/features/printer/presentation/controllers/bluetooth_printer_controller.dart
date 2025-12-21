// lib/features/printer/presentation/controllers/bluetooth_printer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaskredit_1/core/services/bluetooth_printer_service.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class BluetoothPrinterController extends GetxController {
  final BluetoothPrinterService _service = BluetoothPrinterService();
  
  // State
  final RxList<BluetoothDevice> availableDevices = <BluetoothDevice>[].obs;
  final RxList<BluetoothDevice> pairedDevices = <BluetoothDevice>[].obs;
  final Rxn<BluetoothDevice> selectedDevice = Rxn<BluetoothDevice>();
  final RxBool isScanning = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isPrinting = false.obs;
  final RxBool bluetoothEnabled = false.obs;
  final RxString connectionStatus = 'Belum Terhubung'.obs;
  
  // Settings
  final RxString footerNote = 'Terima kasih atas kunjungan Anda'.obs;
  final RxString paperSize = '58mm'.obs; // 58mm or 80mm
  final RxBool autoPrint = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _checkBluetoothState();
    _loadSavedDevice();
  }

  // === BLUETOOTH MANAGEMENT ===

  Future<void> _checkBluetoothState() async {
    final available = await _service.isBluetoothAvailable();
    if (!available) {
      Get.snackbar(
        'Bluetooth Tidak Tersedia',
        'Perangkat ini tidak mendukung Bluetooth',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return;
    }
    
    bluetoothEnabled.value = await _service.isBluetoothEnabled();
    
    // Listen to Bluetooth state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      bluetoothEnabled.value = state == BluetoothState.STATE_ON;
      
      if (!bluetoothEnabled.value && isConnected.value) {
        disconnect();
      }
    });
  }

  Future<void> requestEnableBluetooth() async {
    final result = await _service.requestEnableBluetooth();
    if (result) {
      bluetoothEnabled.value = true;
      Get.snackbar(
        'Berhasil',
        'Bluetooth telah diaktifkan',
        snackPosition: SnackPosition.BOTTOM,
      );
      await getPairedDevices();
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal mengaktifkan Bluetooth',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get paired (bonded) devices
  Future<void> getPairedDevices() async {
    if (!bluetoothEnabled.value) {
      Get.snackbar(
        'Bluetooth Mati',
        'Aktifkan Bluetooth terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final devices = await _service.getPairedDevices();
      pairedDevices.value = devices;
      
      if (devices.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada perangkat yang dipasangkan. Silakan pairing printer di pengaturan Bluetooth HP.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mendapatkan perangkat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Scan for nearby Bluetooth devices
  Future<void> scanDevices() async {
    if (!bluetoothEnabled.value) {
      Get.snackbar(
        'Bluetooth Mati',
        'Aktifkan Bluetooth terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isScanning.value = true;
    availableDevices.clear();

    try {
      final subscription = _service.startDiscovery().listen((result) {
        if (!availableDevices.any((device) => device.address == result.device.address)) {
          availableDevices.add(result.device);
        }
      });

      // Stop after 12 seconds
      Future.delayed(const Duration(seconds: 12), () {
        subscription.cancel();
        isScanning.value = false;
        
        if (availableDevices.isEmpty) {
          Get.snackbar(
            'Info',
            'Tidak ada printer ditemukan. Pastikan printer sudah menyala dan dalam mode pairing.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
      });
    } catch (e) {
      isScanning.value = false;
      Get.snackbar(
        'Error',
        'Gagal scan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Connect to selected device
  Future<void> connectDevice(BluetoothDevice device) async {
    connectionStatus.value = 'Menghubungkan...';

    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menghubungkan ke printer...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final result = await _service.connect(device);
      Get.back(); // Close loading

      if (result == BluetoothPrintResult.success) {
        selectedDevice.value = device;
        isConnected.value = true;
        connectionStatus.value = 'Terhubung';
        
        await _saveDevice(device);
        
        Get.snackbar(
          'Berhasil',
          'Terhubung ke ${device.name ?? device.address}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      } else {
        connectionStatus.value = 'Gagal Terhubung';
        Get.snackbar(
          'Gagal',
          _service.getErrorMessage(result),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
        );
      }
    } catch (e) {
      Get.back();
      connectionStatus.value = 'Error';
      Get.snackbar(
        'Error',
        'Gagal terhubung: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Disconnect from printer
  Future<void> disconnect() async {
    await _service.disconnect();
    isConnected.value = false;
    connectionStatus.value = 'Terputus';
    
    Get.snackbar(
      'Info',
      'Printer terputus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Test connection
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
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mencetak halaman test...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final result = await _service.testPrint();
      Get.back();

      if (result == BluetoothPrintResult.success) {
        Get.snackbar(
          'Berhasil',
          'Test print berhasil!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );
      } else {
        Get.snackbar(
          'Gagal',
          _service.getErrorMessage(result),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
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

  // === PRINTING METHODS ===

  /// Print transaction receipt
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

    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mencetak struk...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final result = await _service.printReceipt(
        transaction: transaction,
        shopName: shopName,
        shopAddress: shopAddress,
        shopPhone: shopPhone,
        footerNote: footerNote.value,
        paperSize: paperSize.value == '58mm' ? PaperSize.mm58 : PaperSize.mm80,
      );

      Get.back();
      isPrinting.value = false;

      if (result == BluetoothPrintResult.success) {
        Get.snackbar(
          'Berhasil',
          'Struk berhasil dicetak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      } else {
        Get.snackbar(
          'Gagal',
          _service.getErrorMessage(result),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
        );
      }
    } catch (e) {
      Get.back();
      isPrinting.value = false;
      Get.snackbar(
        'Error',
        'Gagal mencetak: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Print payment receipt
  Future<void> printPaymentReceipt({
    required String transactionNumber,
    required String customerName,
    required double paymentAmount,
    required double previousDebt,
    required double remainingDebt,
    required String paymentMethod,
    required String shopName,
    String? notes,
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
      final result = await _service.printPaymentReceipt(
        transactionNumber: transactionNumber,
        customerName: customerName,
        paymentAmount: paymentAmount,
        previousDebt: previousDebt,
        remainingDebt: remainingDebt,
        paymentMethod: paymentMethod,
        shopName: shopName,
        notes: notes,
        paperSize: paperSize.value == '58mm' ? PaperSize.mm58 : PaperSize.mm80,
      );

      isPrinting.value = false;

      if (result == BluetoothPrintResult.success) {
        Get.snackbar(
          'Berhasil',
          'Nota pembayaran berhasil dicetak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );
      } else {
        Get.snackbar(
          'Gagal',
          _service.getErrorMessage(result),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isPrinting.value = false;
      Get.snackbar(
        'Error',
        'Gagal mencetak: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // === SETTINGS ===

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    footerNote.value = prefs.getString('footer_note') ?? 'Terima kasih atas kunjungan Anda';
    paperSize.value = prefs.getString('paper_size') ?? '58mm';
    autoPrint.value = prefs.getBool('auto_print') ?? false;
  }

  Future<void> updateFooterNote(String note) async {
    footerNote.value = note;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('footer_note', note);
  }

  Future<void> updatePaperSize(String size) async {
    paperSize.value = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('paper_size', size);
  }

  Future<void> toggleAutoPrint(bool value) async {
    autoPrint.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_print', value);
  }

  Future<void> _saveDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bt_printer_name', device.name ?? '');
    await prefs.setString('bt_printer_address', device.address);
  }

  Future<void> _loadSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('bt_printer_address');
    
    if (savedAddress != null && savedAddress.isNotEmpty) {
      // Try to find in paired devices
      await getPairedDevices();
      
      final device = pairedDevices.firstWhereOrNull(
        (d) => d.address == savedAddress,
      );
      
      if (device != null) {
        selectedDevice.value = device;
        // Auto-connect if desired
        // await connectDevice(device);
      }
    }
  }
}