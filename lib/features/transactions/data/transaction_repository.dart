import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:intl/intl.dart';
import '../presentation/models/cart_state.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_item.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _transactionsRef;
  final CollectionReference _productsRef;
  final CollectionReference _customersRef;

  TransactionRepository()
      : _transactionsRef = FirebaseFirestore.instance.collection('transactions'),
        _productsRef = FirebaseFirestore.instance.collection('products'),
        _customersRef = FirebaseFirestore.instance.collection('customers');

  // --- CREATE TRANSACTION ---
  Future<Transaction> createTransaction(CartState cart, String userId) async {
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
      id: transactionRef.id, // Set ID dokumen
      userId: userId,
      transactionNumber: transactionNumber,
      customerId: cart.selectedCustomer?.id,
      customerName: cart.selectedCustomer?.name,
      items: items,
      totalAmount: cart.totalAmount,
      totalProfit: cart.totalProfit,
      
      paymentStatus: (cart.paymentType == PaymentType.CASH || cart.remainingDebt <= 0)
          ? PaymentStatus.PAID
          : PaymentStatus.PARTIAL,
      
      paymentType: cart.paymentType,
      
      downPayment: cart.downPayment,
      interestRate: cart.interestRate,
      tenor: cart.tenor,

      paidAmount: (cart.paymentType == PaymentType.CASH) 
          ? cart.totalWithInterest
          : cart.downPayment,
      
      remainingDebt: (cart.paymentType == PaymentType.CASH)
          ? 0.0
          : cart.remainingDebt,
      
      transactionDate: DateTime.now(),
      dueDate: cart.dueDate,
      notes: cart.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 1. Simpan Transaksi
    batch.set(transactionRef, newTransaction.toJson());

    // 2. Update Stok Produk
    for (final item in cart.items) {
      final productRef = _productsRef.doc(item.product.id);
      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // 3. Update Utang Pelanggan (jika kredit)
    if (cart.paymentType == PaymentType.CREDIT && cart.selectedCustomer != null) {
      final customerRef = _customersRef.doc(cart.selectedCustomer!.id);
      batch.update(customerRef, {
        'totalDebt': FieldValue.increment(cart.remainingDebt), 
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return newTransaction; // Kembalikan objek transaksi untuk keperluan print
  }

  // --- GENERATE NOMOR ---
  Future<String> _generateTransactionNumber(String userId) async {
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

  // --- READ METHODS ---
  Stream<List<Transaction>> getTransactionsWithDebt(String customerId) {
    return _transactionsRef
        .where('customerId', isEqualTo: customerId)
        .where('paymentStatus', whereIn: ['DEBT', 'PARTIAL'])
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList());
  }

  Stream<List<Transaction>> getTransactionHistory(String userId) {
    return _transactionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('transactionDate', descending: true) 
        .limit(100)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList());
  }
}