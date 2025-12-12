import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:kaskredit_1/shared/models/payment.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _paymentsRef;
  final CollectionReference _transactionsRef;
  final CollectionReference _customersRef;

  PaymentRepository()
    : _paymentsRef = FirebaseFirestore.instance.collection('payments'),
      _transactionsRef = FirebaseFirestore.instance.collection('transactions'),
      _customersRef = FirebaseFirestore.instance.collection('customers');

  /// Process Payment dengan Validasi Lengkap
  Future<void> processPayment({
    required String transactionId,
    required String customerId,
    required double paymentAmount,
    required String paymentMethod,
    required String userId,
    required String customerName,
    String? notes,
  }) async {
    // === VALIDASI INPUT ===
    if (paymentAmount <= 0) {
      throw Exception("Jumlah pembayaran harus lebih dari 0");
    }

    final transactionDocRef = _transactionsRef.doc(transactionId);
    final customerDocRef = _customersRef.doc(customerId);
    final paymentDocRef = _paymentsRef.doc();

    final batch = _firestore.batch();

    try {
      // === GET TRANSACTION ===
      final transactionSnap = await transactionDocRef.get();
      if (!transactionSnap.exists) {
        throw Exception("Transaksi tidak ditemukan!");
      }
      final transaction = Transaction.fromFirestore(transactionSnap);

      // === VALIDASI PEMBAYARAN ===
      // Toleransi 0.01 untuk mengatasi floating point precision
      const tolerance = 0.01;
      
      if (paymentAmount > transaction.remainingDebt + tolerance) {
        throw Exception(
          "Jumlah bayar ${Formatters.currency(paymentAmount)} "
          "melebihi sisa utang ${Formatters.currency(transaction.remainingDebt)}"
        );
      }

      // === HITUNG SISA UTANG ===
      // Pastikan tidak pernah negatif (clamp ke 0)
      double newRemainingDebt = (transaction.remainingDebt - paymentAmount).clamp(0.0, double.infinity);
      
      // Jika sisa < 1 rupiah, anggap lunas
      if (newRemainingDebt < 1.0) {
        newRemainingDebt = 0.0;
      }

      final newPaidAmount = transaction.paidAmount + paymentAmount;
      
      // Tentukan status baru
      final newStatus = (newRemainingDebt <= 0) 
          ? PaymentStatus.PAID
          : PaymentStatus.PARTIAL;

      // === CREATE PAYMENT RECORD ===
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

      // === BATCH OPERATIONS ===
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

      // COMMIT
      await batch.commit();
      
    } catch (e) {
      print('Payment processing error: $e');
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