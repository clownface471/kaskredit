import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

@freezed
class Payment with _$Payment {
  const factory Payment({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    required String userId,
    required String transactionId,
    required String customerId,
    required String customerName,
    
    required double paymentAmount,
    required String paymentMethod,
    
    required double previousDebt,
    required double remainingDebt,
    
    String? notes,
    required String receivedBy,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime paymentDate,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // --- FIX CRASH SERVER TIMESTAMP ---
    if (data['paymentDate'] == null) data['paymentDate'] = Timestamp.now();
    if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
    // ----------------------------------

    return Payment.fromJson(data).copyWith(id: doc.id);
  }

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}