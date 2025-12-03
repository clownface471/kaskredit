import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

/// Print Result Enum - Declare OUTSIDE class
enum PrintResult {
  success,
  connectionFailed,
  printerBusy,
  paperOut,
  printerError,
  timeout,
  cancelled,
}

/// Enhanced Printer Service v2
/// Improvements:
/// - Better error handling dengan error codes
/// - Auto-reconnect mechanism
/// - Print retry logic
/// - Connection pooling
/// - Better logging
class EnhancedPrinterServiceV2 {
  static const PaperSize PAPER_58MM = PaperSize.mm58;
  static const PaperSize PAPER_80MM = PaperSize.mm80;

  NetworkPrinter? _printer;
  String? _lastConnectedIp;
  bool _isConnected = false;
  
  bool get isConnected => _isConnected;

  /// Get error message from result
  String getErrorMessage(PrintResult result) {
    switch (result) {
      case PrintResult.success:
        return 'Print berhasil';
      case PrintResult.connectionFailed:
        return 'Gagal terhubung ke printer. Periksa koneksi WiFi.';
      case PrintResult.printerBusy:
        return 'Printer sedang sibuk. Coba lagi.';
      case PrintResult.paperOut:
        return 'Kertas printer habis.';
      case PrintResult.printerError:
        return 'Printer mengalami error. Restart printer.';
      case PrintResult.timeout:
        return 'Koneksi timeout. Periksa jaringan.';
      case PrintResult.cancelled:
        return 'Print dibatalkan';
    }
  }

  bool get isConnect => _isConnected;

  /// Connect dengan retry mechanism
  Future<bool> connect(
    String printerIp, {
    int port = 9100,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final profile = await CapabilityProfile.load();
        _printer = NetworkPrinter(PAPER_58MM, profile);

        final result = await _printer!.connect(
          printerIp,
          port: port,
          timeout: timeout,
        );

        if (result == PosPrintResult.success) {
          _isConnected = true;
          _lastConnectedIp = printerIp;
          return true;
        }

        // Jika gagal, tunggu sebelum retry
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      } catch (e) {
        print('Connection attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          _isConnected = false;
          return false;
        }
      }
    }
    
    return false;
  }

  /// Disconnect printer
  void disconnect() {
    try {
      _printer?.disconnect();
      _isConnected = false;
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  /// Auto-reconnect jika koneksi terputus
  Future<bool> ensureConnected(String printerIp) async {
    if (_isConnected && _lastConnectedIp == printerIp) {
      return true;
    }
    return await connect(printerIp);
  }

  /// Scan printer dengan parallel processing
  Future<List<PrinterDevice>> scanPrinters({
    String subnet = '192.168.1',
    int port = 9100,
    Duration timeout = const Duration(milliseconds: 500),
  }) async {
    final List<PrinterDevice> devices = [];
    final List<Future<PrinterDevice?>> futures = [];

    for (int i = 1; i <= 255; i++) {
      final String ip = '$subnet.$i';
      futures.add(_checkPrinter(ip, port, timeout));
    }

    final results = await Future.wait(futures);
    devices.addAll(results.whereType<PrinterDevice>());
    
    return devices;
  }

  Future<PrinterDevice?> _checkPrinter(
    String ip,
    int port,
    Duration timeout,
  ) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      
      // Try to get printer info
      socket.add([0x1D, 0x49, 0x01]); // ESC/POS command untuk printer ID
      await Future.delayed(const Duration(milliseconds: 100));
      
      final data = await socket.first.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => Uint8List(0),
      );
      
      socket.destroy();
      
      return PrinterDevice(
        ip: ip,
        port: port,
        name: 'Printer $ip',
        model: data.isNotEmpty ? 'Thermal Printer' : 'Unknown',
        isOnline: true,
      );
    } catch (e) {
      return null;
    }
  }

  /// Test koneksi dengan print test page
  Future<PrintResult> testConnection(
    String printerIp, {
    int port = 9100,
  }) async {
    try {
      final connected = await connect(printerIp, port: port);
      if (!connected) {
        return PrintResult.connectionFailed;
      }

      // Print test page
      _printer!.text(
        'TEST KONEKSI',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      _printer!.feed(1);
      _printer!.text(
        '✓ Printer Terhubung',
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.feed(1);
      _printer!.text(
        DateTime.now().toString(),
        styles: const PosStyles(align: PosAlign.center, width: PosTextSize.size1),
      );
      _printer!.feed(2);
      _printer!.cut();
      
      disconnect();
      return PrintResult.success;
    } catch (e) {
      print('Test connection error: $e');
      return PrintResult.printerError;
    }
  }

  /// Print Receipt dengan retry dan better error handling
  Future<PrintResult> printReceipt({
    required String printerIp,
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
    Uint8List? logoImage,
    bool printQRCode = false,
    PaperSize paperSize = PAPER_58MM,
    int copies = 1,
    bool autoCut = true,
  }) async {
    // Validate inputs
    if (printerIp.isEmpty) {
      return PrintResult.connectionFailed;
    }

    try {
      // Ensure connection
      final connected = await ensureConnected(printerIp);
      if (!connected) {
        return PrintResult.connectionFailed;
      }

      // Print multiple copies
      for (int copy = 1; copy <= copies; copy++) {
        await _printReceiptContent(
          transaction: transaction,
          shopName: shopName,
          shopAddress: shopAddress,
          shopPhone: shopPhone,
          footerNote: footerNote,
          logoImage: logoImage,
          printQRCode: printQRCode,
          paperSize: paperSize,
          autoCut: autoCut && copy == copies, // Cut only on last copy
          copyNumber: copies > 1 ? copy : null,
        );

        // Delay between copies
        if (copy < copies) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      disconnect();
      return PrintResult.success;
    } on SocketException {
      return PrintResult.connectionFailed;
    } on TimeoutException {
      return PrintResult.timeout;
    } catch (e) {
      print('Print error: $e');
      return PrintResult.printerError;
    }
  }

  /// Internal method untuk print content
  Future<void> _printReceiptContent({
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
    Uint8List? logoImage,
    bool printQRCode = false,
    PaperSize paperSize = PAPER_58MM,
    bool autoCut = true,
    int? copyNumber,
  }) async {
    if (_printer == null) throw Exception('Printer not connected');

    // === HEADER ===
    if (logoImage != null) {
      final image = img.decodeImage(logoImage);
      if (image != null) {
        // Resize logo to fit paper width
        final resized = img.copyResize(
          image,
          width: paperSize == PAPER_58MM ? 300 : 450,
        );
        _printer!.image(resized);
        _printer!.feed(1);
      }
    }

    // Shop Name - Prominent
    _printer!.text(
      shopName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );

    // Shop Details
    if (shopAddress != null && shopAddress.isNotEmpty) {
      _printer!.text(
        shopAddress,
        styles: const PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size1,
        ),
      );
    }
    if (shopPhone != null && shopPhone.isNotEmpty) {
      _printer!.text(
        'Telp: $shopPhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    _printer!.feed(1);
    _printer!.text(_getDivider(paperSize));

    // === TRANSACTION INFO ===
    _printer!.text('No: ${transaction.transactionNumber}');
    _printer!.text(
      'Tgl: ${DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(transaction.transactionDate)}',
    );

    if (transaction.customerName != null) {
      _printer!.text('Pelanggan: ${transaction.customerName}');
    }

    // Copy indicator
    if (copyNumber != null) {
      _printer!.text(
        'Salinan ke-$copyNumber',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    _printer!.text(_getDivider(paperSize));
    _printer!.feed(1);

    // === ITEMS ===
    for (final item in transaction.items) {
      // Product name - Bold
      _printer!.text(
        item.productName,
        styles: const PosStyles(bold: true),
      );

      // Quantity x Price = Subtotal
      final qtyLine = '${item.quantity} x ${_formatCurrency(item.sellingPrice)}';
      final subtotalLine = _formatCurrency(item.subtotal);

      _printer!.row([
        PosColumn(
          text: qtyLine,
          width: paperSize == PAPER_58MM ? 8 : 9,
        ),
        PosColumn(
          text: subtotalLine,
          width: paperSize == PAPER_58MM ? 4 : 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    _printer!.text(_getDivider(paperSize, char: '-'));

    // === TOTAL ===
    _printer!.row([
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

    // === PAYMENT DETAILS ===
    if (transaction.paymentType == PaymentType.CREDIT) {
      _printer!.text(_getDivider(paperSize, char: '-'));
      _printer!.text('DETAIL KREDIT:', styles: const PosStyles(bold: true));

      if (transaction.interestRate > 0) {
        _printer!.row([
          PosColumn(text: 'Bunga:', width: 6),
          PosColumn(
            text: '${transaction.interestRate}%',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      if (transaction.tenor > 0) {
        _printer!.row([
          PosColumn(text: 'Tenor:', width: 6),
          PosColumn(
            text: '${transaction.tenor} bulan',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      if (transaction.downPayment > 0) {
        _printer!.row([
          PosColumn(text: 'DP:', width: 6),
          PosColumn(
            text: _formatCurrency(transaction.downPayment),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      _printer!.row([
        PosColumn(text: 'Sisa Utang:', width: 6),
        PosColumn(
          text: _formatCurrency(transaction.remainingDebt),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
    }

    // === PAYMENT TYPE ===
    _printer!.text(_getDivider(paperSize, char: '-'));
    String paymentText = 'Pembayaran: ';
    if (transaction.paymentType == PaymentType.CASH) {
      paymentText += 'TUNAI';
    } else if (transaction.paymentType == PaymentType.CREDIT) {
      paymentText += 'KREDIT';
    } else {
      paymentText += 'TRANSFER';
    }
    _printer!.text(paymentText, styles: const PosStyles(bold: true));

    // === QR CODE ===
    if (printQRCode && transaction.id != null) {
      _printer!.feed(1);
      try {
        _printer!.qrcode(
          'TRX-${transaction.id}',
          align: PosAlign.center,
          size: QRSize.Size6,
        );
        _printer!.text(
          'Scan untuk verifikasi',
          styles: const PosStyles(
            align: PosAlign.center,
            width: PosTextSize.size1,
          ),
        );
      } catch (e) {
        print('QR Code error: $e');
      }
    }

    // === FOOTER ===
    _printer!.feed(1);
    _printer!.text(_getDivider(paperSize));

    if (footerNote != null && footerNote.isNotEmpty) {
      _printer!.text(
        footerNote,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    _printer!.text(
      'Terima Kasih',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    _printer!.text(
      'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      styles: const PosStyles(align: PosAlign.center),
    );

    _printer!.feed(2);
    
    if (autoCut) {
      _printer!.cut();
    }
  }

  /// Print Payment Receipt
  Future<PrintResult> printPaymentReceipt({
    required String printerIp,
    required String transactionNumber,
    required String customerName,
    required double paymentAmount,
    required double previousDebt,
    required double remainingDebt,
    required String paymentMethod,
    required String shopName,
    String? notes,
  }) async {
    try {
      final connected = await ensureConnected(printerIp);
      if (!connected) {
        return PrintResult.connectionFailed;
      }

      // Header
      _printer!.text(
        shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          bold: true,
        ),
      );
      _printer!.text(
        'NOTA PEMBAYARAN',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _printer!.text('================================');

      // Details
      _printer!.text(
        'Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      );
      _printer!.text('Pelanggan: $customerName');
      _printer!.text('Ref: $transactionNumber');
      _printer!.text('--------------------------------');

      // Amount Details
      _printer!.row([
        PosColumn(text: 'Utang Sebelum:', width: 7),
        PosColumn(
          text: _formatCurrency(previousDebt),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      _printer!.row([
        PosColumn(text: 'Dibayar:', width: 7),
        PosColumn(
          text: _formatCurrency(paymentAmount),
          width: 5,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      _printer!.text('================================');

      _printer!.row([
        PosColumn(
          text: 'SISA UTANG:',
          width: 7,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: _formatCurrency(remainingDebt),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]);

      _printer!.text('--------------------------------');
      _printer!.text('Metode: $paymentMethod');

      if (notes != null && notes.isNotEmpty) {
        _printer!.text('Catatan: $notes');
      }

      _printer!.feed(1);
      _printer!.text(
        'Terima Kasih',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      _printer!.feed(2);
      _printer!.cut();
      
      disconnect();
      return PrintResult.success;
    } catch (e) {
      print('Print payment error: $e');
      return PrintResult.printerError;
    }
  }

  /// Print Daily Report
  Future<PrintResult> printDailyReport({
    required String printerIp,
    required String shopName,
    required DateTime reportDate,
    required double totalSales,
    required double totalProfit,
    required int transactionCount,
    required double cashSales,
    required double creditSales,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final connected = await ensureConnected(printerIp);
      if (!connected) {
        return PrintResult.connectionFailed;
      }

      // Header
      _printer!.text(
        shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          bold: true,
        ),
      );
      _printer!.text(
        'LAPORAN HARIAN',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _printer!.text(
        DateFormat('dd MMMM yyyy', 'id_ID').format(reportDate),
        styles: const PosStyles(align: PosAlign.center),
      );
      _printer!.text('================================');

      // Summary
      _printer!.row([
        PosColumn(text: 'Total Transaksi:', width: 7),
        PosColumn(
          text: '$transactionCount',
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      _printer!.row([
        PosColumn(text: 'Total Penjualan:', width: 7),
        PosColumn(
          text: _formatCurrency(totalSales),
          width: 5,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      _printer!.row([
        PosColumn(text: 'Total Profit:', width: 7),
        PosColumn(
          text: _formatCurrency(totalProfit),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      _printer!.text('--------------------------------');

      // Payment breakdown
      _printer!.text('Rincian Pembayaran:', styles: const PosStyles(bold: true));
      _printer!.row([
        PosColumn(text: '  Tunai:', width: 7),
        PosColumn(
          text: _formatCurrency(cashSales),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      _printer!.row([
        PosColumn(text: '  Kredit:', width: 7),
        PosColumn(
          text: _formatCurrency(creditSales),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Additional data
      if (additionalData != null && additionalData.isNotEmpty) {
        _printer!.text('--------------------------------');
        additionalData.forEach((key, value) {
          _printer!.row([
            PosColumn(text: key, width: 7),
            PosColumn(
              text: value.toString(),
              width: 5,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        });
      }

      _printer!.text('================================');
      _printer!.text(
        'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
        styles: const PosStyles(align: PosAlign.center),
      );

      _printer!.feed(2);
      _printer!.cut();
      
      disconnect();
      return PrintResult.success;
    } catch (e) {
      print('Print daily report error: $e');
      return PrintResult.printerError;
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
    final length = size == PAPER_58MM ? 32 : 48;
    return char * length;
  }
}

/// Model untuk printer device
class PrinterDevice {
  final String ip;
  final int port;
  final String name;
  final String model;
  final bool isOnline;

  PrinterDevice({
    required this.ip,
    required this.port,
    required this.name,
    required this.model,
    required this.isOnline,
  });
}