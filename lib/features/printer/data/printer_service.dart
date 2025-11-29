import 'dart:io';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:intl/intl.dart';

// HAPUS: import riverpod, annotation, dan part '...g.dart'

class PrinterService {
  // Scan untuk printer di jaringan
  Future<List<String>> scanPrinters() async {
    final List<String> devices = [];
    
    try {
      // Scan IP range lokal (misal: 192.168.1.1 - 192.168.1.255)
      // Note: Ini scan sederhana, di production mungkin butuh package discovery yg lebih canggih
      for (int i = 1; i <= 255; i++) {
        final String ip = '192.168.1.$i';
        try {
          // Timeout dipercepat biar scan gak kelamaan
          final socket = await Socket.connect(
            ip,
            9100, // Port default printer thermal
            timeout: const Duration(milliseconds: 50), 
          );
          devices.add(ip);
          socket.destroy();
        } catch (e) {
          // Skip jika tidak ada printer di IP ini
        }
      }
    } catch (e) {
      print('Error scanning: $e');
    }
    
    return devices;
  }

  // Print struk
  Future<bool> printReceipt({
    required String printerIp,
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
  }) async {
    try {
      const PaperSize paper = PaperSize.mm58; // Ukuran kertas 58mm
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(paper, profile);

      final PosPrintResult connect = await printer.connect(
        printerIp,
        port: 9100,
        timeout: const Duration(seconds: 5),
      );

      if (connect != PosPrintResult.success) {
        print('Tidak dapat terhubung ke printer: ${connect.msg}');
        return false;
      }

      // === MULAI PRINT ===
      
      // Header Toko
      printer.text(
        shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      
      if (shopAddress != null) {
        printer.text(
          shopAddress,
          styles: const PosStyles(align: PosAlign.center, bold: false),
        );
      }
      
      if (shopPhone != null) {
        printer.text(
          'Telp: $shopPhone',
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      printer.feed(1);
      printer.text('================================');
      
      // Info Transaksi
      printer.text('No: ${transaction.transactionNumber}');
      printer.text(
        'Tgl: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.transactionDate)}',
      );
      
      if (transaction.customerName != null) {
        printer.text('Pelanggan: ${transaction.customerName}');
      }
      
      printer.text('================================');
      printer.feed(1);

      // Item-item
      for (final item in transaction.items) {
        // Nama produk
        printer.text(
          item.productName,
          styles: const PosStyles(bold: true),
        );
        
        // Quantity x Harga = Subtotal
        final qtyLine = '${item.quantity} x ${_formatCurrency(item.sellingPrice)}';
        final subtotalLine = _formatCurrency(item.subtotal);
        
        printer.row([
          PosColumn(
            text: qtyLine,
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: subtotalLine,
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      printer.text('--------------------------------');

      // Total
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

      // Jika ada bunga (kredit)
      if (transaction.interestRate > 0) {
        printer.text('--------------------------------');
        printer.text('DETAIL KREDIT:');
        printer.text('Bunga: ${transaction.interestRate}%');
        printer.text('Tenor: ${transaction.tenor} bulan');
        
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
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      // Payment Type
      printer.text('--------------------------------');
      String paymentText = 'Pembayaran: ';
      if (transaction.paymentType == PaymentType.CASH) {
        paymentText += 'TUNAI';
      } else if (transaction.paymentType == PaymentType.CREDIT) {
        paymentText += 'KREDIT';
      } else {
        paymentText += 'TRANSFER';
      }
      printer.text(paymentText);

      // Footer
      printer.feed(1);
      printer.text('================================');
      
      if (footerNote != null) {
        printer.text(
          footerNote,
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      printer.text(
        'Terima Kasih',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      
      printer.feed(2);
      printer.cut();

      // Disconnect
      printer.disconnect();
      
      return true;
    } catch (e) {
      print('Error printing: $e');
      return false;
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

// HAPUS: Provider Riverpod di bagian bawah