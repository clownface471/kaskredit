// lib/core/services/unified_printer_service.dart
// VERSION DENGAN SAFE PLATFORM CHECK


import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/features/printer/data/printer_service.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

// Helper untuk cek platform dengan aman
class PlatformHelper {
  static bool get isAndroid {
    try {
      return const String.fromEnvironment('dart.library.io') == 'true' &&
             Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }
  
  static bool get isIOS {
    try {
      return const String.fromEnvironment('dart.library.io') == 'true' &&
             Platform.isIOS;
    } catch (_) {
      return false;
    }
  }
  
  static bool get isMobile => isAndroid || isIOS;
  static bool get isWeb => !isMobile;
}



class SimplePlatformHelper {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;
}

enum PrinterConnectionType { wifi, bluetooth, usb }

class PrinterDeviceInfo {
  final String id;
  final String name;
  final PrinterConnectionType type;
  final dynamic device;

  PrinterDeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.device,
  });
}

class UnifiedPrinterService {
  final EnhancedPrinterServiceV2 _wifiService = EnhancedPrinterServiceV2();
  final BlueThermalPrinter _bluetoothPrinter = BlueThermalPrinter.instance;
  
  UsbPort? _usbPort;
  PrinterConnectionType? _currentType;
  bool _isConnected = false;
  
  bool get isConnected => _isConnected;
  
  /// Request Permissions (Safe)
  Future<bool> requestPermissions() async {
    // Skip jika web
    if (kIsWeb) return true;
    
    try {
      if (!kIsWeb && Platform.isAndroid) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();
        
        return statuses.values.every((status) => status.isGranted);
      }
    } catch (e) {
      print('Permission request error: $e');
    }
    return true;
  }
  
  /// Scan All Printers (Safe Platform Check)
  Future<List<PrinterDeviceInfo>> scanAllPrinters() async {
    final List<PrinterDeviceInfo> devices = [];
    
    // 1. WiFi Printers (works everywhere)
    try {
      final wifiPrinters = await _wifiService.scanPrinters();
      devices.addAll(wifiPrinters.map((p) => PrinterDeviceInfo(
        id: p.ip,
        name: 'WiFi: ${p.name}',
        type: PrinterConnectionType.wifi,
        device: p.ip,
      )));
    } catch (e) {
      print('WiFi scan error: $e');
    }
    
    // Skip Bluetooth & USB jika web
    if (kIsWeb) {
      print('Bluetooth and USB not supported on web');
      return devices;
    }
    
    // 2. Bluetooth Printers (mobile only)
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final hasPermission = await requestPermissions();
        if (hasPermission) {
          final bluetoothDevices = await _bluetoothPrinter.getBondedDevices();
          for (var d in bluetoothDevices) {
            devices.add(PrinterDeviceInfo(
              id: d.address ?? '',
              name: 'BT: ${d.name ?? "Unknown"}',
              type: PrinterConnectionType.bluetooth,
              device: d,
            ));
          }
        }
      }
    } catch (e) {
      print('Bluetooth scan error: $e');
    }
    
    // 3. USB Printers (Android only)
    try {
      if (Platform.isAndroid) {
        final usbDevices = await UsbSerial.listDevices();
        for (int i = 0; i < usbDevices.length; i++) {
          final device = usbDevices[i];
          devices.add(PrinterDeviceInfo(
            id: 'usb_$i',
            name: 'USB: ${device.deviceName}',
            type: PrinterConnectionType.usb,
            device: device,
          ));
        }
      }
    } catch (e) {
      print('USB scan error: $e');
    }
    
    return devices;
  }
  
  /// Connect (Safe)
  Future<PrintResult> connect(PrinterDeviceInfo device) async {
    try {
      _currentType = device.type;
      
      switch (device.type) {
        case PrinterConnectionType.wifi:
          final success = await _wifiService.connect(device.device as String);
          _isConnected = success;
          return success ? PrintResult.success : PrintResult.connectionFailed;
          
        case PrinterConnectionType.bluetooth:
          if (kIsWeb) return PrintResult.connectionFailed;
          
          if (device.device == null) {
            return PrintResult.connectionFailed;
          }
          final connected = await _bluetoothPrinter.connect(device.device);
          _isConnected = connected ?? false;
          return _isConnected ? PrintResult.success : PrintResult.connectionFailed;
          
        case PrinterConnectionType.usb:
          if (kIsWeb || !Platform.isAndroid) {
            return PrintResult.connectionFailed;
          }
          
          final usbDevice = device.device as UsbDevice;
          _usbPort = await usbDevice.create();
          if (_usbPort == null) {
            return PrintResult.connectionFailed;
          }
          
          final opened = await _usbPort!.open();
          if (opened) {
            await _usbPort!.setDTR(true);
            await _usbPort!.setRTS(true);
            await _usbPort!.setPortParameters(
              9600,
              UsbPort.DATABITS_8,
              UsbPort.STOPBITS_1,
              UsbPort.PARITY_NONE,
            );
            _isConnected = true;
          }
          return opened ? PrintResult.success : PrintResult.connectionFailed;
      }
    } catch (e) {
      print('Connection error: $e');
      _isConnected = false;
      return PrintResult.connectionFailed;
    }
  }
  
  /// Disconnect
  Future<void> disconnect() async {
    try {
      switch (_currentType) {
        case PrinterConnectionType.wifi:
          _wifiService.disconnect();
          break;
        case PrinterConnectionType.bluetooth:
          if (!kIsWeb) await _bluetoothPrinter.disconnect();
          break;
        case PrinterConnectionType.usb:
          await _usbPort?.close();
          _usbPort = null;
          break;
        default:
          break;
      }
    } catch (e) {
      print('Disconnect error: $e');
    }
    _isConnected = false;
    _currentType = null;
  }
  
  /// Test Connection
  Future<PrintResult> testConnection() async {
    if (!_isConnected) {
      return PrintResult.connectionFailed;
    }
    
    try {
      final commands = await _generateTestPageCommands();
      
      switch (_currentType!) {
        case PrinterConnectionType.wifi:
          return PrintResult.success;
          
        case PrinterConnectionType.bluetooth:
          if (kIsWeb) return PrintResult.connectionFailed;
          await _bluetoothPrinter.writeBytes(Uint8List.fromList(commands));
          return PrintResult.success;
          
        case PrinterConnectionType.usb:
          if (_usbPort != null) {
            await _usbPort!.write(Uint8List.fromList(commands));
            return PrintResult.success;
          }
          return PrintResult.connectionFailed;
      }
    } catch (e) {
      print('Test print error: $e');
      return PrintResult.printerError;
    }
  }
  
  /// Print Receipt
  Future<PrintResult> printReceipt({
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
  }) async {
    if (!_isConnected) {
      return PrintResult.connectionFailed;
    }
    
    try {
      switch (_currentType!) {
        case PrinterConnectionType.wifi:
          return PrintResult.success;
          
        case PrinterConnectionType.bluetooth:
        case PrinterConnectionType.usb:
          if (kIsWeb) return PrintResult.connectionFailed;
          
          final commands = await _generateReceiptCommands(
            transaction: transaction,
            shopName: shopName,
            shopAddress: shopAddress,
            shopPhone: shopPhone,
            footerNote: footerNote,
          );
          
          if (_currentType == PrinterConnectionType.bluetooth) {
            await _bluetoothPrinter.writeBytes(Uint8List.fromList(commands));
          } else if (_usbPort != null) {
            await _usbPort!.write(Uint8List.fromList(commands));
          }
          
          return PrintResult.success;
      }
    } catch (e) {
      print('Print error: $e');
      return PrintResult.printerError;
    }
  }
  
  /// Generate Test Page
  Future<List<int>> _generateTestPageCommands() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    
    List<int> bytes = [];
    bytes += generator.reset();
    bytes += generator.text(
      'TEST KONEKSI',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      '✓ Printer Terhubung',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      DateTime.now().toString(),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();
    
    return bytes;
  }
  
  /// Generate Receipt Commands
  Future<List<int>> _generateReceiptCommands({
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    
    List<int> bytes = [];
    bytes += generator.reset();
    
    // Header
    bytes += generator.text(
      shopName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.feed(1);
    
    if (shopAddress != null && shopAddress.isNotEmpty) {
      bytes += generator.text(
        shopAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (shopPhone != null && shopPhone.isNotEmpty) {
      bytes += generator.text(
        'Telp: $shopPhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.feed(1);
    bytes += generator.text('================================');
    
    // Transaction Info
    bytes += generator.text('No: ${transaction.transactionNumber}');
    bytes += generator.text(
      'Tgl: ${DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(transaction.transactionDate)}',
    );
    if (transaction.customerName != null) {
      bytes += generator.text('Pelanggan: ${transaction.customerName}');
    }
    bytes += generator.text('================================');
    bytes += generator.feed(1);
    
    // Items
    for (final item in transaction.items) {
      bytes += generator.text(
        item.productName,
        styles: const PosStyles(bold: true),
      );
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity} x ${_formatCurrency(item.sellingPrice)}',
          width: 8,
        ),
        PosColumn(
          text: _formatCurrency(item.subtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    
    bytes += generator.text('--------------------------------');
    
    // Total
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: _formatCurrency(transaction.totalAmount),
        width: 6,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.right,
          height: PosTextSize.size2,
        ),
      ),
    ]);
    
    // Credit Details
    if (transaction.paymentType == PaymentType.CREDIT && transaction.remainingDebt > 0) {
      bytes += generator.text('--------------------------------');
      bytes += generator.text('DETAIL KREDIT:', styles: const PosStyles(bold: true));
      bytes += generator.row([
        PosColumn(text: 'Sisa Utang:', width: 6),
        PosColumn(
          text: _formatCurrency(transaction.remainingDebt),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
    }
    
    // Footer
    bytes += generator.feed(1);
    bytes += generator.text('================================');
    
    if (footerNote != null && footerNote.isNotEmpty) {
      bytes += generator.text(
        footerNote,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    
    bytes += generator.text(
      'Terima Kasih',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();
    
    return bytes;
  }
  
  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
  
  String getErrorMessage(PrintResult result) {
    return _wifiService.getErrorMessage(result);
  }
}