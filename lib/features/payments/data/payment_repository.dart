import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:kaskredit_1/shared/models/payment.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _paymentsRef;
  final CollectionReference _transactionsRef;
  final CollectionReference _customersRef;

  PaymentRepository()
    : _paymentsRef = FirebaseFirestore.instance.collection('payments'),
      _transactionsRef = FirebaseFirestore.instance.collection('transactions'),
      _customersRef = FirebaseFirestore.instance.collection('customers');

  // === CREATE PAYMENT ===
  Future<void> processPayment({
    required String transactionId,
    required String customerId,
    required double paymentAmount,
    required String paymentMethod,
    required String userId,
    required String customerName,
    String? notes,
  }) async {
    final transactionDocRef = _transactionsRef.doc(transactionId);
    final customerDocRef = _customersRef.doc(customerId);
    final paymentDocRef = _paymentsRef.doc(); 

    final batch = _firestore.batch();

    try {
      final transactionSnap = await transactionDocRef.get();
      if (!transactionSnap.exists) {
        throw Exception("Transaksi tidak ditemukan!");
      }
      final transaction = Transaction.fromFirestore(transactionSnap);

      if (paymentAmount <= 0) {
        throw Exception("Jumlah bayar tidak boleh nol.");
      }
      
      // PERBAIKAN 1: Naikkan toleransi menjadi 1.0 (atau lebih)
      // Ini untuk mengakomodasi pembulatan tampilan (contoh: 0.7 dibulatkan jadi 1 di UI)
      if (paymentAmount > transaction.remainingDebt + 1.0) {
        throw Exception("Jumlah bayar melebihi sisa utang.");
      }

      // PERBAIKAN 2: Pastikan sisa utang tidak minus (Clamp to 0)
      // Jika bayar 101 untuk utang 100.5, sisa utang jadi 0 (bukan -0.5)
      double newRemainingDebt = transaction.remainingDebt - paymentAmount;
      if (newRemainingDebt < 0) {
        newRemainingDebt = 0;
      }

      final newPaidAmount = transaction.paidAmount + paymentAmount;
      
      // PERBAIKAN 3: Cek status lunas
      final newStatus = (newRemainingDebt <= 0) // Gunakan <= 0 biar aman
          ? PaymentStatus.PAID
          : PaymentStatus.PARTIAL;

      final newPayment = Payment(
        id: paymentDocRef.id,
        userId: userId,
        transactionId: transactionId,
        customerId: customerId,
        customerName: customerName,
        paymentAmount: paymentAmount,
        paymentMethod: paymentMethod,
        previousDebt: transaction.remainingDebt,
        remainingDebt: newRemainingDebt,
        notes: notes,
        receivedBy: userId,
        paymentDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // 1. Simpan Payment
      batch.set(paymentDocRef, newPayment.toJson());

      // 2. Update Transaksi
      batch.update(transactionDocRef, {
        'remainingDebt': newRemainingDebt,
        'paidAmount': newPaidAmount,
        'paymentStatus': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Update Saldo Utang Customer
      batch.update(customerDocRef, {
        'totalDebt': FieldValue.increment(-paymentAmount), 
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Gagal memproses pembayaran: $e");
    }
  }

  // === READ METHODS ===
  Stream<List<Payment>> getPaymentsByCustomer(String customerId) {
    return _paymentsRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Payment>> getAllPayments(String userId) {
    return _paymentsRef
        .where('userId', isEqualTo: userId)
        .orderBy('paymentDate', descending: true)
        .limit(100) 
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList(),
        );
  }
}