import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

part 'dashboard_repository.g.dart';

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

    // --- QUERY 1: Transaksi Hari Ini (DIPERBAIKI) ---
    // Indeks yang dipakai: transactions(userId ASC, transactionDate DESC)
    final txSnap = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('transactionDate', isGreaterThanOrEqualTo: startOfDay)
        .where('transactionDate', isLessThanOrEqualTo: endOfDay)
        // TAMBAHKAN ORDERBY INI:
        .orderBy('transactionDate', descending: true) 
        .get();

    todayTransactions = txSnap.docs.length;
    for (final doc in txSnap.docs) {
      final tx = Transaction.fromFirestore(doc);
      todaySales += tx.totalAmount;
      todayProfit += tx.totalProfit;
      if (tx.paymentType == PaymentType.CREDIT) {
        todayNewDebt += tx.remainingDebt;
      }
    }

    // --- QUERY 2: Pelanggan (DIPERBAIKI) ---
    // Indeks yang dipakai: customers(userId ASC, totalDebt DESC)
    final customerSnap = await _firestore
        .collection('customers')
        .where('userId', isEqualTo: userId)
        .where('totalDebt', isGreaterThan: 0)
        // TAMBAHKAN ORDERBY INI:
        .orderBy('totalDebt', descending: true) 
        .get();

    totalDebtors = customerSnap.docs.length;
    for (final doc in customerSnap.docs) {
      totalOutstandingDebt += (doc.data()['totalDebt'] as num).toDouble();
    }

    // --- QUERY 3: Produk (DIPERBAIKI) ---
    // Indeks yang dipakai: products(userId ASC, isActive ASC, name ASC)
    final productSnap = await _firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        // TAMBAHKAN ORDERBY INI:
        .orderBy('name', descending: false)
        .get();

    for (final doc in productSnap.docs) {
      final stock = (doc.data()['stock'] as num).toInt();
      final minStock = (doc.data()['minStock'] as num).toInt();
      if (stock <= minStock) {
        lowStockProducts++;
      }
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

@Riverpod(keepAlive: true)
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepository();
}