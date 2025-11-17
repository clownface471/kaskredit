import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/shared/models/payment.dart';
import 'package:kaskredit_1/shared/models/transaction.dart'; // Kita butuh ini

part 'payment_repository.g.dart'; // Akan dibuat

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _paymentsRef;
  final CollectionReference _transactionsRef;
  final CollectionReference _customersRef;

  PaymentRepository()
    : _paymentsRef = FirebaseFirestore.instance.collection('payments'),
      _transactionsRef = FirebaseFirestore.instance.collection('transactions'),
      _customersRef = FirebaseFirestore.instance.collection('customers');

  // === FUNGSI UTAMA: PROSES PEMBAYARAN ===
  Future<void> processPayment({
    required String transactionId,
    required String customerId,
    required double paymentAmount,
    required String paymentMethod,
    required String userId,
    required String customerName,
    String? notes,
  }) async {
    // 1. Dapatkan referensi dokumen
    final transactionDocRef = _transactionsRef.doc(transactionId);
    final customerDocRef = _customersRef.doc(customerId);
    final paymentDocRef = _paymentsRef.doc(); // Buat ID baru untuk payment

    // 2. Gunakan batch write
    final batch = _firestore.batch();

    try {
      // 3. Ambil data transaksi saat ini (untuk validasi)
      final transactionSnap = await transactionDocRef.get();
      if (!transactionSnap.exists) {
        throw Exception("Transaksi tidak ditemukan!");
      }
      final transaction = Transaction.fromFirestore(transactionSnap);

      // 4. Validasi pembayaran
      if (paymentAmount <= 0) {
        throw Exception("Jumlah bayar tidak boleh nol.");
      }
      // Tambahkan toleransi 0.01 untuk error floating point
      if (paymentAmount > transaction.remainingDebt + 0.01) {
        throw Exception("Jumlah bayar melebihi sisa utang.");
      }

      // 5. Hitung nilai baru
      final newRemainingDebt = transaction.remainingDebt - paymentAmount;
      final newPaidAmount = transaction.paidAmount + paymentAmount;
      // Tentukan status baru (lunas atau masih sebagian)
      final newStatus = (newRemainingDebt < 0.01)
          ? PaymentStatus.PAID
          : PaymentStatus.PARTIAL;

      // 6. Buat objek Payment baru
      final newPayment = Payment(
        userId: userId,
        transactionId: transactionId,
        customerId: customerId,
        customerName: customerName,
        paymentAmount: paymentAmount,
        paymentMethod: paymentMethod,
        previousDebt: transaction.remainingDebt,
        remainingDebt: newRemainingDebt,
        notes: notes,
        receivedBy: userId, // Asumsi user yg login yg terima
        paymentDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // 7. Tambahkan 3 operasi ke batch:
      // A. Buat catatan Payment
      batch.set(paymentDocRef, newPayment.toJson());

      // B. Update Transaksi
      batch.update(transactionDocRef, {
        'remainingDebt': newRemainingDebt,
        'paidAmount': newPaidAmount,
        'paymentStatus': newStatus.name, // "PAID" or "PARTIAL"
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // C. Update Customer
      batch.update(customerDocRef, {
        'totalDebt': FieldValue.increment(
          -paymentAmount,
        ), // Kurangi total utang
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 8. Eksekusi batch
      await batch.commit();
    } catch (e) {
      // Tangkap error validasi atau eksekusi
      throw Exception("Gagal memproses pembayaran: $e");
    }
  }

  // === READ ===
  // (Nanti kita pakai ini untuk riwayat)
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
        .orderBy('paymentDate', descending: true) // Terbaru di atas
        .limit(100) // Batasi 100 pembayaran terakhir
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList(),
        );
  }
}

// Provider Riverpod
@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository();
}
