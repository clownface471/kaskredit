import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

/// Enhanced Printer Service dengan fitur lengkap
/// Mendukung:
/// - Print receipt transaksi
/// - Print laporan harian
/// - Print nota pembayaran
/// - Custom logo/header
/// - Bluetooth & WiFi printer
/// - QR Code untuk transaksi
class EnhancedPrinterService {
  // Konstanta untuk ukuran kertas
  static const PaperSize PAPER_58MM = PaperSize.mm58;
  static const PaperSize PAPER_80MM = PaperSize.mm80;

  // Status printer
  bool _isConnected = false;
  NetworkPrinter? _printer;

  bool get isConnected => _isConnected;

  /// Scan printer di jaringan lokal
  /// Returns: List IP address yang ditemukan
  Future<List<String>> scanPrinters({
    String subnet = '192.168.1',
    int port = 9100,
    Duration timeout = const Duration(milliseconds: 100),
  }) async {
    final List<String> devices = [];
    final List<Future<void>> futures = [];

    // Scan parallel untuk performa lebih baik
    for (int i = 1; i <= 255; i++) {
      final String ip = '$subnet.$i';
      futures.add(
        _checkPrinterAtIP(ip, port, timeout).then((found) {
          if (found) devices.add(ip);
        }),
      );
    }

    await Future.wait(futures);
    return devices;
  }

  Future<bool> _checkPrinterAtIP(String ip, int port, Duration timeout) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test koneksi ke printer
  Future<bool> testConnection(String printerIp, {int port = 9100}) async {
    try {
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PAPER_58MM, profile);

      final result = await printer.connect(
        printerIp,
        port: port,
        timeout: const Duration(seconds: 5),
      );

      if (result == PosPrintResult.success) {
        // Print test page
        printer.text('TEST KONEKSI BERHASIL',
            styles: const PosStyles(align: PosAlign.center, bold: true));
        printer.text(DateTime.now().toString(),
            styles: const PosStyles(align: PosAlign.center));
        printer.feed(2);
        printer.cut();
        printer.disconnect();
        return true;
      }
      return false;
    } catch (e) {
      print('Test connection error: $e');
      return false;
    }
  }

  /// Print Receipt Transaksi (Enhanced Version)
  Future<bool> printReceipt({
    required String printerIp,
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
    Uint8List? logoImage, // Optional logo
    bool printQRCode = false,
    PaperSize paperSize = PAPER_58MM,
  }) async {
    try {
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(paperSize, profile);

      final result = await printer.connect(
        printerIp,
        port: 9100,
        timeout: const Duration(seconds: 5),
      );

      if (result != PosPrintResult.success) {
        return false;
      }

      // === PRINT HEADER ===
      // Logo jika ada
      if (logoImage != null) {
        final image = img.decodeImage(logoImage);
        if (image != null) {
          printer.image(image);
          printer.feed(1);
        }
      }

      // Shop Name
      printer.text(
        shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );

      // Shop Details
      if (shopAddress != null) {
        printer.text(shopAddress,
            styles: const PosStyles(align: PosAlign.center));
      }
      if (shopPhone != null) {
        printer.text('Telp: $shopPhone',
            styles: const PosStyles(align: PosAlign.center));
      }

      printer.feed(1);
      printer.text(_getDivider(paperSize));

      // === TRANSACTION INFO ===
      printer.text('No: ${transaction.transactionNumber}');
      printer.text(
          'Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate)}');

      if (transaction.customerName != null) {
        printer.text('Pelanggan: ${transaction.customerName}');
      }

      printer.text(_getDivider(paperSize));
      printer.feed(1);

      // === ITEMS ===
      for (final item in transaction.items) {
        // Product name
        printer.text(item.productName, styles: const PosStyles(bold: true));

        // Quantity x Price = Subtotal
        final qtyLine =
            '${item.quantity} x ${_formatCurrency(item.sellingPrice)}';
        final subtotalLine = _formatCurrency(item.subtotal);

        printer.row([
          PosColumn(
            text: qtyLine,
            width: paperSize == PAPER_58MM ? 8 : 9,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: subtotalLine,
            width: paperSize == PAPER_58MM ? 4 : 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      printer.text(_getDivider(paperSize, char: '-'));

      // === TOTAL ===
      printer.row([
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
        printer.text(_getDivider(paperSize, char: '-'));
        printer.text('DETAIL KREDIT:', styles: const PosStyles(bold: true));

        if (transaction.interestRate > 0) {
          printer.row([
            PosColumn(text: 'Bunga:', width: 6),
            PosColumn(
              text: '${transaction.interestRate}%',
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }

        if (transaction.tenor > 0) {
          printer.row([
            PosColumn(text: 'Tenor:', width: 6),
            PosColumn(
              text: '${transaction.tenor} bulan',
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }

        if (transaction.downPayment > 0) {
          printer.row([
            PosColumn(text: 'DP:', width: 6),
            PosColumn(
              text: _formatCurrency(transaction.downPayment),
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }

        printer.row([
          PosColumn(text: 'Sisa Utang:', width: 6),
          PosColumn(
            text: _formatCurrency(transaction.remainingDebt),
            width: 6,
            styles:
                const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]);
      }

      // === PAYMENT TYPE ===
      printer.text(_getDivider(paperSize, char: '-'));
      String paymentText = 'Pembayaran: ';
      if (transaction.paymentType == PaymentType.CASH) {
        paymentText += 'TUNAI';
      } else if (transaction.paymentType == PaymentType.CREDIT) {
        paymentText += 'KREDIT';
      } else {
        paymentText += 'TRANSFER';
      }
      printer.text(paymentText, styles: const PosStyles(bold: true));

      // === QR CODE (Optional) ===
      if (printQRCode && transaction.id != null) {
        printer.feed(1);
        printer.qrcode(
          'TRX-${transaction.id}',
          align: PosAlign.center,
          size: QRSize.Size6,
        );
        printer.text('Scan untuk verifikasi',
            styles: const PosStyles(align: PosAlign.center, width: PosTextSize.size1));
      }

      // === FOOTER ===
      printer.feed(1);
      printer.text(_getDivider(paperSize));

      if (footerNote != null && footerNote.isNotEmpty) {
        printer.text(footerNote,
            styles: const PosStyles(align: PosAlign.center));
      }

      printer.text('Terima Kasih',
          styles: const PosStyles(align: PosAlign.center, bold: true));

      // Print timestamp
      printer.text(
        'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
        styles: const PosStyles(align: PosAlign.center),
      );

      printer.feed(2);
      printer.cut();
      printer.disconnect();

      return true;
    } catch (e) {
      print('Print error: $e');
      return false;
    }
  }

  /// Print Nota Pembayaran Utang
  Future<bool> printPaymentReceipt({
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
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PAPER_58MM, profile);

      final result = await printer.connect(printerIp, port: 9100);
      if (result != PosPrintResult.success) return false;

      // Header
      printer.text(shopName,
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2, bold: true));
      printer.text('NOTA PEMBAYARAN',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.text('================================');

      // Details
      printer.text('Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      printer.text('Pelanggan: $customerName');
      printer.text('Ref: $transactionNumber');
      printer.text('--------------------------------');

      // Amount Details
      printer.row([
        PosColumn(text: 'Utang Sebelum:', width: 7),
        PosColumn(
            text: _formatCurrency(previousDebt),
            width: 5,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      printer.row([
        PosColumn(text: 'Dibayar:', width: 7),
        PosColumn(
            text: _formatCurrency(paymentAmount),
            width: 5,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);

      printer.text('================================');

      printer.row([
        PosColumn(text: 'SISA UTANG:', width: 7, styles: const PosStyles(bold: true)),
        PosColumn(
            text: _formatCurrency(remainingDebt),
            width: 5,
            styles: const PosStyles(
                align: PosAlign.right,
                bold: true,
                height: PosTextSize.size2)),
      ]);

      printer.text('--------------------------------');
      printer.text('Metode: $paymentMethod');

      if (notes != null && notes.isNotEmpty) {
        printer.text('Catatan: $notes');
      }

      printer.feed(1);
      printer.text('Terima Kasih',
          styles: const PosStyles(align: PosAlign.center, bold: true));

      printer.feed(2);
      printer.cut();
      printer.disconnect();

      return true;
    } catch (e) {
      print('Print payment error: $e');
      return false;
    }
  }

  /// Print Laporan Harian
  Future<bool> printDailyReport({
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
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PAPER_58MM, profile);

      final result = await printer.connect(printerIp, port: 9100);
      if (result != PosPrintResult.success) return false;

      // Header
      printer.text(shopName,
          styles: const PosStyles(
              align: PosAlign.center, height: PosTextSize.size2, bold: true));
      printer.text('LAPORAN HARIAN',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.text(DateFormat('dd MMMM yyyy', 'id_ID').format(reportDate),
          styles: const PosStyles(align: PosAlign.center));
      printer.text('================================');

      // Summary
      printer.row([
        PosColumn(text: 'Total Transaksi:', width: 7),
        PosColumn(
            text: '$transactionCount',
            width: 5,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      printer.row([
        PosColumn(text: 'Total Penjualan:', width: 7),
        PosColumn(
            text: _formatCurrency(totalSales),
            width: 5,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);

      printer.row([
        PosColumn(text: 'Total Profit:', width: 7),
        PosColumn(
            text: _formatCurrency(totalProfit),
            width: 5,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      printer.text('--------------------------------');

      // Payment breakdown
      printer.text('Rincian Pembayaran:', styles: const PosStyles(bold: true));
      printer.row([
        PosColumn(text: '  Tunai:', width: 7),
        PosColumn(
            text: _formatCurrency(cashSales),
            width: 5,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      printer.row([
        PosColumn(text: '  Kredit:', width: 7),
        PosColumn(
            text: _formatCurrency(creditSales),
            width: 5,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      // Additional data if provided
      if (additionalData != null && additionalData.isNotEmpty) {
        printer.text('--------------------------------');
        additionalData.forEach((key, value) {
          printer.row([
            PosColumn(text: key, width: 7),
            PosColumn(
                text: value.toString(),
                width: 5,
                styles: const PosStyles(align: PosAlign.right)),
          ]);
        });
      }

      printer.text('================================');
      printer.text(
          'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          styles: const PosStyles(align: PosAlign.center));

      printer.feed(2);
      printer.cut();
      printer.disconnect();

      return true;
    } catch (e) {
      print('Print daily report error: $e');
      return false;
    }
  }

  // Helper methods
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