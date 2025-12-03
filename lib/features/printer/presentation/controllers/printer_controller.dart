import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';

/// Enhanced Printer Controller v2
/// Features:
/// - Print queue management
/// - Auto-retry failed prints
/// - Connection status monitoring
/// - Print job history
/// - Multiple printer profiles
class EnhancedPrinterControllerV2 extends GetxController {
  // === STATE ===
  final RxnString printerIp = RxnString();
  final RxBool autoPrint = false.obs;
  final RxString footerNote = ''.obs;
  final RxBool isScanning = false.obs;
  final RxList<String> foundPrinters = <String>[].obs;
  final RxBool isPrinting = false.obs;
  
  // Print settings
  final RxBool printQRCode = false.obs;
  final RxInt copies = 1.obs;
  final RxString paperSize = '58mm'.obs;
  final RxBool autoCut = true.obs;
  
  // Connection status
  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  
  // Print Queue
  final RxList<PrintJob> printQueue = <PrintJob>[].obs;
  final RxBool isProcessingQueue = false.obs;
  
  // Print history
  final RxList<PrintHistoryItem> printHistory = <PrintHistoryItem>[].obs;
  
  // Printer profiles
  final RxList<PrinterProfile> printerProfiles = <PrinterProfile>[].obs;
  final RxnString activePrinterId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadPrintHistory();
    _loadPrinterProfiles();
    _startQueueProcessor();
  }

  // === SETTINGS MANAGEMENT ===

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    printerIp.value = prefs.getString('printer_ip');
    autoPrint.value = prefs.getBool('auto_print') ?? false;
    footerNote.value = prefs.getString('footer_note') ?? 
        'Terima kasih atas kunjungan Anda';
    printQRCode.value = prefs.getBool('print_qr_code') ?? false;
    copies.value = prefs.getInt('print_copies') ?? 1;
    paperSize.value = prefs.getString('paper_size') ?? '58mm';
    autoCut.value = prefs.getBool('auto_cut') ?? true;
    activePrinterId.value = prefs.getString('active_printer_id');
  }

  Future<void> saveSettings({
    String? ip,
    String? note,
    bool? qrCode,
    int? printCopies,
    String? size,
    bool? cut,
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
    if (cut != null) {
      await prefs.setBool('auto_cut', cut);
      autoCut.value = cut;
    }

    GetXUtils.showSuccess("Pengaturan tersimpan");
  }

  Future<void> toggleAutoPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_print', value);
    autoPrint.value = value;
  }

  // === CONNECTION MANAGEMENT ===

  Future<void> checkConnection() async {
    if (printerIp.value == null) {
      connectionStatus.value = 'No printer configured';
      isConnected.value = false;
      return;
    }

    connectionStatus.value = 'Checking...';
    
    try {
      // Simulate connection check
      // Replace with actual printer service check
      await Future.delayed(const Duration(seconds: 1));
      
      isConnected.value = true;
      connectionStatus.value = 'Connected';
    } catch (e) {
      isConnected.value = false;
      connectionStatus.value = 'Connection failed';
    }
  }

  // === PRINT QUEUE MANAGEMENT ===

  void addToPrintQueue(PrintJob job) {
    printQueue.add(job);
    
    // Auto-process if not already processing
    if (!isProcessingQueue.value) {
      _processQueue();
    }
  }

  void _startQueueProcessor() {
    // Check queue every 5 seconds
    ever(printQueue, (_) {
      if (printQueue.isNotEmpty && !isProcessingQueue.value) {
        _processQueue();
      }
    });
  }

  Future<void> _processQueue() async {
    if (isProcessingQueue.value || printQueue.isEmpty) return;

    isProcessingQueue.value = true;

    while (printQueue.isNotEmpty) {
      final job = printQueue.first;
      
      try {
        // Process print job
        final success = await _executePrintJob(job);
        
        if (success) {
          // Remove from queue and add to history
          printQueue.removeAt(0);
          await addPrintHistory(PrintHistoryItem(
            timestamp: DateTime.now(),
            type: job.type,
            transactionNumber: job.reference,
            status: 'success',
          ));
        } else {
          // Retry logic
          job.retryCount++;
          if (job.retryCount >= 3) {
            // Max retries reached, remove and mark as failed
            printQueue.removeAt(0);
            await addPrintHistory(PrintHistoryItem(
              timestamp: DateTime.now(),
              type: job.type,
              transactionNumber: job.reference,
              status: 'failed',
            ));
            
            GetXUtils.showError(
              'Print gagal setelah 3 kali percobaan: ${job.reference}',
            );
          } else {
            // Wait before retry
            await Future.delayed(Duration(seconds: job.retryCount * 2));
          }
        }
      } catch (e) {
        print('Queue processing error: $e');
        job.retryCount++;
      }
    }

    isProcessingQueue.value = false;
  }

  Future<bool> _executePrintJob(PrintJob job) async {
    // Execute actual print job
    // This should call your printer service
    // Return true if successful, false otherwise
    
    try {
      // Simulate print execution
      await Future.delayed(const Duration(seconds: 2));
      return true; // Success
    } catch (e) {
      return false;
    }
  }

  void clearQueue() {
    printQueue.clear();
    GetXUtils.showSuccess('Print queue cleared');
  }

  void cancelPrintJob(String jobId) {
    printQueue.removeWhere((job) => job.id == jobId);
    GetXUtils.showSuccess('Print job cancelled');
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
    
    // Keep only last 100
    if (printHistory.length > 100) {
      printHistory.removeRange(100, printHistory.length);
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

  // Get statistics
  int get totalPrints => printHistory.length;
  int get successfulPrints => 
      printHistory.where((h) => h.status == 'success').length;
  int get failedPrints => 
      printHistory.where((h) => h.status == 'failed').length;
  double get successRate => totalPrints > 0 
      ? (successfulPrints / totalPrints) * 100 
      : 0;

  // === PRINTER PROFILES ===

  Future<void> _loadPrinterProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getStringList('printer_profiles') ?? [];
    
    printerProfiles.value = profilesJson.map((json) {
      final parts = json.split('|');
      if (parts.length >= 4) {
        return PrinterProfile(
          id: parts[0],
          name: parts[1],
          ipAddress: parts[2],
          isDefault: parts[3] == 'true',
          port: parts.length > 4 ? int.tryParse(parts[4]) ?? 9100 : 9100,
        );
      }
      return null;
    }).whereType<PrinterProfile>().toList();
  }

  Future<void> addPrinterProfile(PrinterProfile profile) async {
    // If this is the first printer or marked as default
    if (printerProfiles.isEmpty || profile.isDefault) {
      // Set other profiles as non-default
      for (var p in printerProfiles) {
        p.isDefault = false;
      }
      
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

  Future<void> updatePrinterProfile(PrinterProfile profile) async {
    final index = printerProfiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      printerProfiles[index] = profile;
      await _savePrinterProfiles();
      GetXUtils.showSuccess("Printer ${profile.name} diupdate");
    }
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
      // Update all profiles
      for (var p in printerProfiles) {
        p.isDefault = p.id == profileId;
      }
      
      activePrinterId.value = profile.id;
      printerIp.value = profile.ipAddress;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_printer_id', profile.id);
      await prefs.setString('printer_ip', profile.ipAddress);
      
      await _savePrinterProfiles();
      await checkConnection();
      
      GetXUtils.showSuccess("Printer aktif: ${profile.name}");
    }
  }

  Future<void> _savePrinterProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = printerProfiles.map((profile) {
      return '${profile.id}|${profile.name}|${profile.ipAddress}|${profile.isDefault}|${profile.port}';
    }).toList();
    
    await prefs.setStringList('printer_profiles', profilesJson);
  }

  PrinterProfile? get activeProfile {
    if (activePrinterId.value == null) return null;
    return printerProfiles.firstWhereOrNull(
      (p) => p.id == activePrinterId.value,
    );
  }

  // === SCANNER ===

  Future<void> scanPrinters() async {
    isScanning.value = true;
    foundPrinters.clear();

    try {
      // Use enhanced printer service to scan
      // This is a placeholder - replace with actual implementation
      await Future.delayed(const Duration(seconds: 3));
      
      // Example results
      foundPrinters.addAll([
        '192.168.1.100',
        '192.168.1.101',
      ]);

      if (foundPrinters.isEmpty) {
        GetXUtils.showInfo("Tidak ditemukan printer di jaringan");
      } else {
        GetXUtils.showSuccess("Ditemukan ${foundPrinters.length} printer");
      }
    } catch (e) {
      GetXUtils.showError("Gagal scan: $e");
    } finally {
      isScanning.value = false;
    }
  }
}

/// Model untuk Print Job
class PrintJob {
  final String id;
  final String type; // 'receipt', 'payment', 'report'
  final String reference; // transaction number or reference
  final Map<String, dynamic> data;
  int retryCount;
  final DateTime createdAt;

  PrintJob({
    required this.id,
    required this.type,
    required this.reference,
    required this.data,
    this.retryCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Model untuk Print History
class PrintHistoryItem {
  final DateTime timestamp;
  final String type;
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
  final int port;
  bool isDefault;

  PrinterProfile({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.port = 9100,
    this.isDefault = false,
  });
}