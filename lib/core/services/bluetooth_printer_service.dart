// lib/core/services/bluetooth_printer_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:intl/intl.dart';

/// Enhanced Bluetooth Thermal Printer Service
/// Optimized untuk printer thermal 58mm/80mm via Bluetooth
class BluetoothPrinterService {
  static final BluetoothPrinterService _instance = BluetoothPrinterService._internal();
  factory BluetoothPrinterService() => _instance;
  BluetoothPrinterService._internal();

  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  
  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // === BLUETOOTH MANAGEMENT ===

  /// Check Bluetooth availability
  Future<bool> isBluetoothAvailable() async {
    try {
      final isAvailable = await FlutterBluetoothSerial.instance.isAvailable;
      return isAvailable ?? false;
    } catch (e) {
      print('Error checking Bluetooth: $e');
      return false;
    }
  }

  /// Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      final isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      return isEnabled ?? false;
    } catch (e) {
      print('Error checking Bluetooth state: $e');
      return false;
    }
  }

  /// Request to enable Bluetooth
  Future<bool> requestEnableBluetooth() async {
    try {
      final result = await FlutterBluetoothSerial.instance.requestEnable();
      return result ?? false;
    } catch (e) {
      print('Error enabling Bluetooth: $e');
      return false;
    }
  }

  /// Scan for paired Bluetooth devices
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      return devices;
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  /// Scan for available Bluetooth devices (discovery)
  Stream<BluetoothDiscoveryResult> startDiscovery() {
    return FlutterBluetoothSerial.instance.startDiscovery();
  }

  /// Connect to Bluetooth device
  Future<BluetoothPrintResult> connect(BluetoothDevice device) async {
    try {
      // Disconnect existing connection
      if (_isConnected) {
        await disconnect();
      }

      // Establish connection
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;
      _isConnected = true;

      print('✅ Connected to ${device.name}');
      return BluetoothPrintResult.success;
    } on Exception catch (e) {
      print('❌ Connection failed: $e');
      _isConnected = false;
      _connectedDevice = null;
      
      if (e.toString().contains('timeout')) {
        return BluetoothPrintResult.timeout;
      }
      return BluetoothPrintResult.connectionFailed;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    try {
      await _connection?.close();
      _connection = null;
      _connectedDevice = null;
      _isConnected = false;
      print('✅ Disconnected from printer');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // === PRINTING METHODS ===

  /// Test connection by printing test page
  Future<BluetoothPrintResult> testPrint() async {
    if (!_isConnected || _connection == null) {
      return BluetoothPrintResult.notConnected;
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      
      List<int> bytes = [];
      
      // Header
      bytes += generator.text(
        'TEST KONEKSI',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.feed(1);
      
      // Status
      bytes += generator.text(
        '✓ Printer Terhubung',
        styles: PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.feed(1);
      
      // Timestamp
      bytes += generator.text(
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
        styles: PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.feed(2);
      bytes += generator.cut();

      // Send to printer
      _connection!.output.add(Uint8List.fromList(bytes));
      await _connection!.output.allSent;

      return BluetoothPrintResult.success;
    } catch (e) {
      print('Test print error: $e');
      return BluetoothPrintResult.printError;
    }
  }

  /// Print transaction receipt
  Future<BluetoothPrintResult> printReceipt({
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
    PaperSize paperSize = PaperSize.mm58,
    bool autoCut = true,
  }) async {
    if (!_isConnected || _connection == null) {
      return BluetoothPrintResult.notConnected;
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(paperSize, profile);
      
      List<int> bytes = [];
      
      // === HEADER ===
      bytes += generator.text(
        shopName,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      
      if (shopAddress != null && shopAddress.isNotEmpty) {
        bytes += generator.text(
          shopAddress,
          styles: PosStyles(align: PosAlign.center),
        );
      }
      
      if (shopPhone != null && shopPhone.isNotEmpty) {
        bytes += generator.text(
          'Telp: $shopPhone',
          styles: PosStyles(align: PosAlign.center),
        );
      }
      
      bytes += generator.feed(1);
      bytes += generator.text(_getDivider(paperSize));
      
      // === TRANSACTION INFO ===
      bytes += generator.text('No: ${transaction.transactionNumber}');
      bytes += generator.text(
        'Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate)}',
      );
      
      if (transaction.customerName != null) {
        bytes += generator.text('Pelanggan: ${transaction.customerName}');
      }
      
      bytes += generator.text(_getDivider(paperSize));
      bytes += generator.feed(1);
      
      // === ITEMS ===
      for (final item in transaction.items) {
        // Product name
        bytes += generator.text(
          item.productName,
          styles: PosStyles(bold: true),
        );
        
        // Quantity x Price = Subtotal
        bytes += generator.row([
          PosColumn(
            text: '${item.quantity} x ${_formatCurrency(item.sellingPrice)}',
            width: paperSize == PaperSize.mm58 ? 8 : 9,
          ),
          PosColumn(
            text: _formatCurrency(item.subtotal),
            width: paperSize == PaperSize.mm58 ? 4 : 3,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      
      bytes += generator.text(_getDivider(paperSize, char: '-'));
      
      // === TOTAL ===
      bytes += generator.row([
        PosColumn(
          text: 'TOTAL:',
          width: 6,
          styles: PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: _formatCurrency(transaction.totalAmount),
          width: 6,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
            height: PosTextSize.size2,
          ),
        ),
      ]);
      
      // === PAYMENT DETAILS ===
      if (transaction.paymentType == PaymentType.CREDIT) {
        bytes += generator.text(_getDivider(paperSize, char: '-'));
        bytes += generator.text('DETAIL KREDIT:', styles: PosStyles(bold: true));
        
        if (transaction.interestRate > 0) {
          bytes += generator.row([
            PosColumn(text: 'Bunga:', width: 6),
            PosColumn(
              text: '${transaction.interestRate}%',
              width: 6,
              styles: PosStyles(align: PosAlign.right),
            ),
          ]);
        }
        
        if (transaction.tenor > 0) {
          bytes += generator.row([
            PosColumn(text: 'Tenor:', width: 6),
            PosColumn(
              text: '${transaction.tenor} bulan',
              width: 6,
              styles: PosStyles(align: PosAlign.right),
            ),
          ]);
        }
        
        if (transaction.downPayment > 0) {
          bytes += generator.row([
            PosColumn(text: 'DP:', width: 6),
            PosColumn(
              text: _formatCurrency(transaction.downPayment),
              width: 6,
              styles: PosStyles(align: PosAlign.right),
            ),
          ]);
        }
        
        bytes += generator.row([
          PosColumn(text: 'Sisa Utang:', width: 6),
          PosColumn(
            text: _formatCurrency(transaction.remainingDebt),
            width: 6,
            styles: PosStyles(align: PosAlign.right, bold: true),
          ),
        ]);
      }
      
      // === PAYMENT TYPE ===
      bytes += generator.text(_getDivider(paperSize, char: '-'));
      String paymentText = 'Pembayaran: ';
      if (transaction.paymentType == PaymentType.CASH) {
        paymentText += 'TUNAI';
      } else if (transaction.paymentType == PaymentType.CREDIT) {
        paymentText += 'KREDIT';
      } else {
        paymentText += 'TRANSFER';
      }
      bytes += generator.text(paymentText, styles: PosStyles(bold: true));
      
      // === FOOTER ===
      bytes += generator.feed(1);
      bytes += generator.text(_getDivider(paperSize));
      
      if (footerNote != null && footerNote.isNotEmpty) {
        bytes += generator.text(
          footerNote,
          styles: PosStyles(align: PosAlign.center),
        );
      }
      
      bytes += generator.text(
        'Terima Kasih',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      
      bytes += generator.text(
        'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
        styles: PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.feed(2);
      
      if (autoCut) {
        bytes += generator.cut();
      }
      
      // Send to printer
      _connection!.output.add(Uint8List.fromList(bytes));
      await _connection!.output.allSent;
      
      return BluetoothPrintResult.success;
    } catch (e) {
      print('Print receipt error: $e');
      return BluetoothPrintResult.printError;
    }
  }

  /// Print payment receipt
  Future<BluetoothPrintResult> printPaymentReceipt({
    required String transactionNumber,
    required String customerName,
    required double paymentAmount,
    required double previousDebt,
    required double remainingDebt,
    required String paymentMethod,
    required String shopName,
    String? notes,
    PaperSize paperSize = PaperSize.mm58,
  }) async {
    if (!_isConnected || _connection == null) {
      return BluetoothPrintResult.notConnected;
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(paperSize, profile);
      
      List<int> bytes = [];
      
      // Header
      bytes += generator.text(
        shopName,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          bold: true,
        ),
      );
      
      bytes += generator.text(
        'NOTA PEMBAYARAN',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      
      bytes += generator.text(_getDivider(paperSize));
      
      // Details
      bytes += generator.text(
        'Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      );
      bytes += generator.text('Pelanggan: $customerName');
      bytes += generator.text('Ref: $transactionNumber');
      bytes += generator.text(_getDivider(paperSize, char: '-'));
      
      // Amount Details
      bytes += generator.row([
        PosColumn(text: 'Utang Sebelum:', width: 7),
        PosColumn(
          text: _formatCurrency(previousDebt),
          width: 5,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'Dibayar:', width: 7),
        PosColumn(
          text: _formatCurrency(paymentAmount),
          width: 5,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      
      bytes += generator.text(_getDivider(paperSize));
      
      bytes += generator.row([
        PosColumn(
          text: 'SISA UTANG:',
          width: 7,
          styles: PosStyles(bold: true),
        ),
        PosColumn(
          text: _formatCurrency(remainingDebt),
          width: 5,
          styles: PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]);
      
      bytes += generator.text(_getDivider(paperSize, char: '-'));
      bytes += generator.text('Metode: $paymentMethod');
      
      if (notes != null && notes.isNotEmpty) {
        bytes += generator.text('Catatan: $notes');
      }
      
      bytes += generator.feed(1);
      bytes += generator.text(
        'Terima Kasih',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      
      bytes += generator.feed(2);
      bytes += generator.cut();
      
      // Send to printer
      _connection!.output.add(Uint8List.fromList(bytes));
      await _connection!.output.allSent;
      
      return BluetoothPrintResult.success;
    } catch (e) {
      print('Print payment error: $e');
      return BluetoothPrintResult.printError;
    }
  }

  // === HELPER METHODS ===

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _getDivider(PaperSize size, {String char = '='}) {
    final length = size == PaperSize.mm58 ? 32 : 48;
    return char * length;
  }

  String getErrorMessage(BluetoothPrintResult result) {
    switch (result) {
      case BluetoothPrintResult.success:
        return 'Print berhasil';
      case BluetoothPrintResult.notConnected:
        return 'Printer belum terhubung';
      case BluetoothPrintResult.connectionFailed:
        return 'Gagal terhubung ke printer';
      case BluetoothPrintResult.bluetoothDisabled:
        return 'Bluetooth tidak aktif';
      case BluetoothPrintResult.bluetoothNotAvailable:
        return 'Bluetooth tidak tersedia di perangkat ini';
      case BluetoothPrintResult.timeout:
        return 'Koneksi timeout';
      case BluetoothPrintResult.printError:
        return 'Gagal mencetak. Coba lagi.';
      case BluetoothPrintResult.deviceNotFound:
        return 'Printer tidak ditemukan';
    }
  }
}

/// Print result enum
enum BluetoothPrintResult {
  success,
  notConnected,
  connectionFailed,
  bluetoothDisabled,
  bluetoothNotAvailable,
  timeout,
  printError,
  deviceNotFound,
}