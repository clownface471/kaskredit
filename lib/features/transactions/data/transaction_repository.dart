import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../presentation/models/cart_state.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_item.dart';

part 'transaction_repository.g.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _transactionsRef;
  final CollectionReference _productsRef;
  final CollectionReference _customersRef;

  TransactionRepository()
      : _transactionsRef = FirebaseFirestore.instance.collection('transactions'),
        _productsRef = FirebaseFirestore.instance.collection('products'),
        _customersRef = FirebaseFirestore.instance.collection('customers');

  // --- FUNGSI CREATE TRANSACTION (Sudah ada) ---
  Future<void> createTransaction(CartState cart, String userId) async {
    // ... (kode createTransaction Anda yang sudah berfungsi)
    final transactionNumber = await _generateTransactionNumber(userId);
    final batch = _firestore.batch();
    final transactionRef = _transactionsRef.doc();

    final List<TransactionItem> items = cart.items.map((cartItem) {
      return TransactionItem(
        productId: cartItem.product.id!,
        productName: cartItem.product.name,
        quantity: cartItem.quantity,
        sellingPrice: cartItem.product.sellingPrice,
        capitalPrice: cartItem.product.capitalPrice,
        subtotal: cartItem.subtotal,
      );
    }).toList();

    final newTransaction = Transaction(
      userId: userId,
      transactionNumber: transactionNumber,
      customerId: cart.selectedCustomer?.id,
      customerName: cart.selectedCustomer?.name,
      items: items,
      totalAmount: cart.totalAmount, // Total barang
      totalProfit: cart.totalProfit,
      
      paymentStatus: (cart.paymentType == PaymentType.CASH || cart.remainingDebt <= 0)
          ? PaymentStatus.PAID
          : PaymentStatus.PARTIAL, // Gunakan PARTIAL jika ada DP
      
      paymentType: cart.paymentType,
      
      // --- SIMPAN DATA KREDIT BARU ---
      downPayment: cart.downPayment,
      interestRate: cart.interestRate,
      tenor: cart.tenor,
      // --- AKHIR PERUBAHAN DATA KREDIT ---

      paidAmount: (cart.paymentType == PaymentType.CASH) 
          ? cart.totalWithInterest // Jika tunai, bayar lunas (termasuk bunga jika ada)
          : cart.downPayment,     // Jika kredit, bayar sejumlah DP
      
      remainingDebt: (cart.paymentType == PaymentType.CASH)
          ? 0.0 // Lunas
          : cart.remainingDebt, // Ambil dari kalkulasi (Total+Bunga - DP)
      
      transactionDate: DateTime.now(),
      dueDate: cart.dueDate, // (Kita belum implementasi UI-nya, tapi datanya siap)
      notes: cart.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    // --- AKHIR PERUBAHAN OBJEK ---

    batch.set(transactionRef, newTransaction.toJson());

    // Update stok produk (logika ini tetap sama)
    for (final item in cart.items) {
      final productRef = _productsRef.doc(item.product.id);
      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Update utang pelanggan (logika ini diubah sedikit)
    if (cart.paymentType == PaymentType.CREDIT && cart.selectedCustomer != null) {
      final customerRef = _customersRef.doc(cart.selectedCustomer!.id);
      // Tambahkan utang sejumlah 'remainingDebt' (bukan totalAmount lagi)
      batch.update(customerRef, {
        'totalDebt': FieldValue.increment(cart.remainingDebt), 
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // --- FUNGSI GENERATE NOMOR (Sudah ada) ---
  Future<String> _generateTransactionNumber(String userId) async {
    // ... (kode _generateTransactionNumber Anda yang sudah berfungsi)
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final query = await _transactionsRef
        .where('userId', isEqualTo: userId)
        .where('transactionNumber', isGreaterThanOrEqualTo: 'TRX-$dateStr-0000')
        .where('transactionNumber', isLessThanOrEqualTo: 'TRX-$dateStr-9999')
        .orderBy('transactionNumber', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return 'TRX-$dateStr-0001';
    }
    
    final lastTxNum = query.docs.first.get('transactionNumber') as String;
    final lastNumStr = lastTxNum.split('-').last;

    final lastNum = int.tryParse(lastNumStr) ?? 0;
    final newNum = (lastNum + 1).toString().padLeft(4, '0');
    return 'TRX-$dateStr-$newNum';
  }

  // --- METHOD YANG HILANG (TAMBAHKAN INI) ---
  Stream<List<Transaction>> getTransactionsWithDebt(String customerId) {
    return _transactionsRef
        .where('customerId', isEqualTo: customerId)
        .where('paymentStatus', whereIn: ['DEBT', 'PARTIAL'])
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList());
  }
} // <-- PASTIKAN METHOD BARU ADA DI ATAS KURUNG TUTUP INI

// --- PROVIDER (Sudah ada) ---
@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository();
}