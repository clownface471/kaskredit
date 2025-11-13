import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaskredit_1/shared/models/transaction_item.dart'; // Import sub-model kita

part 'transaction.freezed.dart';
part 'transaction.g.dart';

// Helper function untuk konversi timestamp
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

DateTime? _nullableDateTimeFromTimestamp(Timestamp? timestamp) {
  // Jika timestamp-nya null, kembalikan null
  return timestamp?.toDate();
}

Timestamp? _nullableDateTimeToTimestamp(DateTime? dateTime) {
  // Jika dateTime-nya null, kembalikan null
  return dateTime != null ? Timestamp.fromDate(dateTime) : null;
}

// Enum untuk Status Pembayaran (sesuai blueprint [cite: 106-107])
enum PaymentStatus { PAID, DEBT, PARTIAL }

// Enum untuk Tipe Pembayaran (sesuai blueprint [cite: 108-111])
enum PaymentType { CASH, CREDIT, TRANSFER }

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    required String userId,
    required String transactionNumber,
    String? customerId,
    String? customerName, // Denormalized
    
    required List<TransactionItem> items, // List dari sub-model
    
    required double totalAmount,
    required double totalProfit,
    
    required PaymentStatus paymentStatus,
    required PaymentType paymentType,

    @Default(0.0) double downPayment,  // Uang Muka (DP)
    @Default(0.0) double interestRate, // Bunga (misal: 10 untuk 10%)
    @Default(0) int tenor,             // Jangka waktu (misal: 3 untuk 3 bulan)
    
    @Default(0.0) double paidAmount,
    @Default(0.0) double remainingDebt,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime transactionDate,
    @JsonKey(fromJson: _nullableDateTimeFromTimestamp, toJson: _nullableDateTimeToTimestamp)
    DateTime? dueDate, // Opsional untuk kredit
    
    String? notes,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction.fromJson(data).copyWith(id: doc.id);
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}