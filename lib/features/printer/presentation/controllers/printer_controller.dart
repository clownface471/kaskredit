import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';

/// Enhanced Printer Controller dengan fitur:
/// - Auto print settings
/// - Print history
/// - Multiple printer profiles
/// - Print queue management
class EnhancedPrinterController extends GetxController {
  // State
  final RxnString printerIp = RxnString();
  final RxBool autoPrint = false.obs;
  final RxString footerNote = ''.obs;
  final RxBool isScanning = false.obs;
  final RxList<String> foundPrinters = <String>[].obs;
  final RxBool isPrinting = false.obs;
  
  // NEW: Print settings
  final RxBool printQRCode = false.obs;
  final RxInt copies = 1.obs;
  final RxString paperSize = '58mm'.obs; // '58mm' or '80mm'
  
  // NEW: Print history (last 50 prints)
  final RxList<PrintHistoryItem> printHistory = <PrintHistoryItem>[].obs;
  
  // NEW: Multiple printer profiles
  final RxList<PrinterProfile> printerProfiles = <PrinterProfile>[].obs;
  final RxnString activePrinterId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadPrintHistory();
    _loadPrinterProfiles();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    printerIp.value = prefs.getString('printer_ip');
    autoPrint.value = prefs.getBool('auto_print') ?? false;
    footerNote.value = prefs.getString('footer_note') ?? 'Terima kasih atas kunjungan Anda';
    printQRCode.value = prefs.getBool('print_qr_code') ?? false;
    copies.value = prefs.getInt('print_copies') ?? 1;
    paperSize.value = prefs.getString('paper_size') ?? '58mm';
    activePrinterId.value = prefs.getString('active_printer_id');
  }

  Future<void> saveSettings({
    String? ip,
    String? note,
    bool? qrCode,
    int? printCopies,
    String? size,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (ip != null) {
      await prefs.setString('printer_ip', ip);
      printerIp.value = ip;
    }

    if (note != null) {
      await prefs.setString('footer_note', note);
      footerNote.value = note;
    }

    if (qrCode != null) {
      await prefs.setBool('print_qr_code', qrCode);
      printQRCode.value = qrCode;
    }

    if (printCopies != null) {
      await prefs.setInt('print_copies', printCopies);
      copies.value = printCopies;
    }

    if (size != null) {
      await prefs.setString('paper_size', size);
      paperSize.value = size;
    }

    GetXUtils.showSuccess("Pengaturan tersimpan");
  }

  Future<void> toggleAutoPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_print', value);
    autoPrint.value = value;
  }

  Future<void> scanPrinters() async {
    isScanning.value = true;
    foundPrinters.clear();

    try {
      // Simulate scan - replace with actual implementation
      await Future.delayed(const Duration(seconds: 2));
      
      // Example: Add found printers
      // In real implementation, use EnhancedPrinterService.scanPrinters()
      foundPrinters.addAll(['192.168.1.100', '192.168.1.101']);

      if (foundPrinters.isEmpty) {
        GetXUtils.showInfo("Tidak ditemukan printer di jaringan lokal");
      }
    } catch (e) {
      GetXUtils.showError("Gagal scan: $e");
    } finally {
      isScanning.value = false;
    }
  }

  // === PRINT HISTORY ===
  
  Future<void> _loadPrintHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('print_history') ?? [];
    
    printHistory.value = historyJson.map((json) {
      final parts = json.split('|');
      if (parts.length >= 4) {
        return PrintHistoryItem(
          timestamp: DateTime.parse(parts[0]),
          type: parts[1],
          transactionNumber: parts[2],
          status: parts[3],
        );
      }
      return null;
    }).whereType<PrintHistoryItem>().toList();
  }

  Future<void> addPrintHistory(PrintHistoryItem item) async {
    printHistory.insert(0, item);
    
    // Keep only last 50
    if (printHistory.length > 50) {
      printHistory.removeRange(50, printHistory.length);
    }

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    final historyJson = printHistory.map((item) {
      return '${item.timestamp.toIso8601String()}|${item.type}|${item.transactionNumber}|${item.status}';
    }).toList();
    
    await prefs.setStringList('print_history', historyJson);
  }

  void clearPrintHistory() async {
    printHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('print_history');
    GetXUtils.showSuccess("History dihapus");
  }

  // === PRINTER PROFILES ===
  
  Future<void> _loadPrinterProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getStringList('printer_profiles') ?? [];
    
    printerProfiles.value = profilesJson.map((json) {
      final parts = json.split('|');
      if (parts.length >= 3) {
        return PrinterProfile(
          id: parts[0],
          name: parts[1],
          ipAddress: parts[2],
          isDefault: parts.length > 3 ? parts[3] == 'true' : false,
        );
      }
      return null;
    }).whereType<PrinterProfile>().toList();
  }

  Future<void> addPrinterProfile(PrinterProfile profile) async {
    // If this is the first printer or marked as default, set as active
    if (printerProfiles.isEmpty || profile.isDefault) {
      activePrinterId.value = profile.id;
      printerIp.value = profile.ipAddress;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_printer_id', profile.id);
      await prefs.setString('printer_ip', profile.ipAddress);
    }

    printerProfiles.add(profile);
    await _savePrinterProfiles();
    GetXUtils.showSuccess("Printer ${profile.name} ditambahkan");
  }

  Future<void> removePrinterProfile(String profileId) async {
    printerProfiles.removeWhere((p) => p.id == profileId);
    
    if (activePrinterId.value == profileId) {
      if (printerProfiles.isNotEmpty) {
        await setActivePrinter(printerProfiles.first.id);
      } else {
        activePrinterId.value = null;
        printerIp.value = null;
      }
    }
    
    await _savePrinterProfiles();
    GetXUtils.showSuccess("Printer dihapus");
  }

  Future<void> setActivePrinter(String profileId) async {
    final profile = printerProfiles.firstWhereOrNull((p) => p.id == profileId);
    if (profile != null) {
      activePrinterId.value = profile.id;
      printerIp.value = profile.ipAddress;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_printer_id', profile.id);
      await prefs.setString('printer_ip', profile.ipAddress);
      
      GetXUtils.showSuccess("Printer aktif: ${profile.name}");
    }
  }

  Future<void> _savePrinterProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = printerProfiles.map((profile) {
      return '${profile.id}|${profile.name}|${profile.ipAddress}|${profile.isDefault}';
    }).toList();
    
    await prefs.setStringList('printer_profiles', profilesJson);
  }

  PrinterProfile? get activeProfile {
    if (activePrinterId.value == null) return null;
    return printerProfiles.firstWhereOrNull((p) => p.id == activePrinterId.value);
  }

  // === PRINT QUEUE (Future enhancement) ===
  // Bisa ditambahkan untuk handle multiple print jobs
}

/// Model untuk Print History
class PrintHistoryItem {
  final DateTime timestamp;
  final String type; // 'receipt', 'payment', 'report'
  final String transactionNumber;
  final String status; // 'success', 'failed'

  PrintHistoryItem({
    required this.timestamp,
    required this.type,
    required this.transactionNumber,
    required this.status,
  });
}

/// Model untuk Printer Profile
class PrinterProfile {
  final String id;
  final String name;
  final String ipAddress;
  final bool isDefault;

  PrinterProfile({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.isDefault = false,
  });
}