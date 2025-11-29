import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:kaskredit_1/shared/models/sales_report.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _transactionsRef;

  ReportRepository()
      : _transactionsRef = FirebaseFirestore.instance.collection('transactions');

  // === FUNGSI UTAMA: GENERATE LAPORAN PENJUALAN ===
  Future<SalesReport> generateSalesReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Tentukan rentang waktu (jam 00:00 di awal s/d 23:59 di akhir)
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    // 2. Siapkan variabel hasil
    double totalSales = 0.0;
    double totalProfit = 0.0;
    int totalTransactions = 0;
    double cashSales = 0.0;
    double creditSales = 0.0;
    
    // Map untuk melacak produk terlaris & harian
    Map<String, ProductStats> productStatsMap = {};
    Map<DateTime, DailyStats> dailyStatsMap = {};

    // 3. Query: Ambil semua transaksi dalam rentang waktu
    // Note: Firestore butuh Composite Index untuk query ini (userId + transactionDate)
    // Jika belum ada index, log error akan memberikan link untuk membuatnya.
    final txSnap = await _transactionsRef
        .where('userId', isEqualTo: userId)
        .where('transactionDate', isGreaterThanOrEqualTo: start)
        .where('transactionDate', isLessThanOrEqualTo: end)
        .orderBy('transactionDate')
        .get();
    
    totalTransactions = txSnap.docs.length;

    // 4. Proses setiap transaksi
    for (final doc in txSnap.docs) {
      final tx = Transaction.fromFirestore(doc);
      
      // Akumulasi total
      totalSales += tx.totalAmount;
      totalProfit += tx.totalProfit;

      // Akumulasi tipe pembayaran
      if (tx.paymentType == PaymentType.CASH) {
        cashSales += tx.totalAmount;
      } else {
        creditSales += tx.totalAmount;
      }

      // Akumulasi statistik harian
      final dateOnly = DateTime(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day);
      
      final dailyStat = dailyStatsMap[dateOnly] ?? DailyStats(date: dateOnly, totalSales: 0, totalProfit: 0);
      
      dailyStatsMap[dateOnly] = dailyStat.copyWith(
        totalSales: dailyStat.totalSales + tx.totalAmount,
        totalProfit: dailyStat.totalProfit + tx.totalProfit,
      );

      // Akumulasi produk terlaris
      for (final item in tx.items) {
        final stat = productStatsMap[item.productId] ?? ProductStats(
          productId: item.productId,
          productName: item.productName,
          quantitySold: 0,
          totalSales: 0,
          totalProfit: 0,
        );

        productStatsMap[item.productId] = stat.copyWith(
          quantitySold: stat.quantitySold + item.quantity,
          totalSales: stat.totalSales + item.subtotal,
          totalProfit: stat.totalProfit + (item.sellingPrice - item.capitalPrice) * item.quantity,
        );
      }
    }

    // 5. Ubah Map ke List dan urutkan
    final dailyBreakdown = dailyStatsMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
      
    final topProducts = productStatsMap.values.toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold)); // Urutkan dari terlaris

    // 6. Kembalikan Laporan Lengkap
    return SalesReport(
      startDate: start,
      endDate: end,
      totalSales: totalSales,
      totalProfit: totalProfit,
      totalTransactions: totalTransactions,
      cashSales: cashSales,
      creditSales: creditSales,
      dailyBreakdown: dailyBreakdown,
      topProducts: topProducts.take(10).toList(), // Ambil 10 teratas
    );
  }
}