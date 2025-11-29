import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaskredit_1/shared/models/transaction_item.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

DateTime? _nullableDateTimeFromTimestamp(Timestamp? timestamp) {
  return timestamp?.toDate();
}

Timestamp? _nullableDateTimeToTimestamp(DateTime? dateTime) {
  return dateTime != null ? Timestamp.fromDate(dateTime) : null;
}

enum PaymentStatus { PAID, DEBT, PARTIAL }
enum PaymentType { CASH, CREDIT, TRANSFER }

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    required String userId,
    required String transactionNumber,
    String? customerId,
    String? customerName,
    
    required List<TransactionItem> items,
    
    required double totalAmount,
    required double totalProfit,
    
    required PaymentStatus paymentStatus,
    required PaymentType paymentType,

    @Default(0.0) double downPayment,
    @Default(0.0) double interestRate,
    @Default(0) int tenor,
    
    @Default(0.0) double paidAmount,
    @Default(0.0) double remainingDebt,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime transactionDate,
    @JsonKey(fromJson: _nullableDateTimeFromTimestamp, toJson: _nullableDateTimeToTimestamp)
    DateTime? dueDate,
    
    String? notes,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // --- FIX CRASH SERVER TIMESTAMP ---
    // Jika null (masih proses server), pakai waktu lokal sekarang
    if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
    if (data['updatedAt'] == null) data['updatedAt'] = Timestamp.now();
    if (data['transactionDate'] == null) data['transactionDate'] = Timestamp.now();
    // ----------------------------------

    return Transaction.fromJson(data).copyWith(id: doc.id);
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}