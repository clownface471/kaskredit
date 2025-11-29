import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DashboardStats> getDashboardStats(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    double todaySales = 0.0;
    double todayProfit = 0.0;
    int todayTransactions = 0;
    double todayNewDebt = 0.0;
    double totalOutstandingDebt = 0.0;
    int totalDebtors = 0;
    int lowStockProducts = 0;

    try {
      // --- QUERY 1: Transaksi Hari Ini ---
      final txSnap = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('transactionDate', isGreaterThanOrEqualTo: startOfDay)
          .where('transactionDate', isLessThanOrEqualTo: endOfDay)
          .orderBy('transactionDate', descending: true)
          .get();

      todayTransactions = txSnap.docs.length;
      for (final doc in txSnap.docs) {
        try {
          final tx = Transaction.fromFirestore(doc);
          todaySales += tx.totalAmount;
          todayProfit += tx.totalProfit;
          if (tx.paymentType == PaymentType.CREDIT) {
            todayNewDebt += tx.remainingDebt;
          }
        } catch (e) {
          print('Error parsing transaction ${doc.id}: $e');
        }
      }
    } catch (e) {
      print('Error querying transactions: $e');
    }

    try {
      // --- QUERY 2: Pelanggan ---
      final customerSnap = await _firestore
          .collection('customers')
          .where('userId', isEqualTo: userId)
          .where('totalDebt', isGreaterThan: 0)
          .orderBy('totalDebt', descending: true)
          .get();

      totalDebtors = customerSnap.docs.length;
      for (final doc in customerSnap.docs) {
        try {
          final data = doc.data();
          if (data['totalDebt'] != null) {
            totalOutstandingDebt += (data['totalDebt'] as num).toDouble();
          }
        } catch (e) {
          print('Error parsing customer ${doc.id}: $e');
        }
      }
    } catch (e) {
      print('Error querying customers: $e');
    }

    try {
      // --- QUERY 3: Produk ---
      final productSnap = await _firestore
          .collection('products')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('name', descending: false)
          .get();

      for (final doc in productSnap.docs) {
        try {
          final data = doc.data();
          final stock = (data['stock'] as num?)?.toInt() ?? 0;
          final minStock = (data['minStock'] as num?)?.toInt() ?? 5;
          if (stock <= minStock) {
            lowStockProducts++;
          }
        } catch (e) {
          print('Error parsing product ${doc.id}: $e');
        }
      }
    } catch (e) {
      print('Error querying products: $e');
    }

    return DashboardStats(
      todaySales: todaySales,
      todayProfit: todayProfit,
      todayTransactions: todayTransactions,
      todayNewDebt: todayNewDebt,
      totalOutstandingDebt: totalOutstandingDebt,
      totalDebtors: totalDebtors,
      lowStockProducts: lowStockProducts,
    );
  }
}