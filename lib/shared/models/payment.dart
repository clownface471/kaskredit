import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'payment.freezed.dart'; // Akan dibuat
part 'payment.g.dart';     // Akan dibuat

// Helper function untuk konversi timestamp
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

@freezed
class Payment with _$Payment {
  const factory Payment({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    required String userId,
    required String transactionId, // Transaksi mana yang dibayar
    required String customerId,
    required String customerName,  // Denormalized
    
    required double paymentAmount, // Jumlah yang dibayar
    required String paymentMethod, // CASH atau TRANSFER
    
    required double previousDebt,  // Sisa utang di transaksi SEBELUM bayar
    required double remainingDebt, // Sisa utang di transaksi SETELAH bayar
    
    String? notes,
    required String receivedBy,    // Siapa kasir/owner yg terima
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime paymentDate,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Payment.fromJson(data).copyWith(id: doc.id);
  }

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}