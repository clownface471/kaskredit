import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    String? id,
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
    required DateTime paymentDate,
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  /// ✅ FIXED: Better error handling for Firestore parsing
  factory Payment.fromFirestore(DocumentSnapshot doc) {
    try {
      // Safely extract data
      final data = doc.data();
      
      // Handle null or invalid data
      if (data == null) {
        throw Exception('Document data is null for payment ${doc.id}');
      }

      // ✅ CRITICAL FIX: Ensure data is Map<String, dynamic>
      Map<String, dynamic> paymentData;
      
      if (data is Map<String, dynamic>) {
        paymentData = data;
      } else {
        // Convert if it's another map type (handles LegacyJavaScriptObject)
        paymentData = Map<String, dynamic>.from(data as Map);
      }

      // ✅ Parse Timestamps safely
      DateTime parseTimestamp(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is Timestamp) return value.toDate();
        if (value is DateTime) return value;
        if (value is String) return DateTime.parse(value);
        return DateTime.now();
      }

      // ✅ Parse double safely
      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      // ✅ Parse string safely
      String parseString(dynamic value, {String defaultValue = ''}) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      return Payment(
        id: doc.id,
        userId: parseString(paymentData['userId'], defaultValue: ''),
        transactionId: parseString(paymentData['transactionId'], defaultValue: ''),
        customerId: parseString(paymentData['customerId'], defaultValue: ''),
        customerName: parseString(paymentData['customerName'], defaultValue: 'Unknown'),
        paymentAmount: parseDouble(paymentData['paymentAmount']),
        paymentMethod: parseString(paymentData['paymentMethod'], defaultValue: 'CASH'),
        previousDebt: parseDouble(paymentData['previousDebt']),
        remainingDebt: parseDouble(paymentData['remainingDebt']),
        notes: paymentData['notes'] != null ? parseString(paymentData['notes']) : null,
        receivedBy: parseString(paymentData['receivedBy'], defaultValue: ''),
        paymentDate: parseTimestamp(paymentData['paymentDate']),
        createdAt: parseTimestamp(paymentData['createdAt']),
      );
    } catch (e, stackTrace) {
      // ✅ Better error logging
      print('❌ ERROR parsing Payment from Firestore:');
      print('Document ID: ${doc.id}');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      
      // Return a fallback Payment to prevent app crash
      return Payment(
        id: doc.id,
        userId: '',
        transactionId: '',
        customerId: '',
        customerName: 'Error Loading',
        paymentAmount: 0.0,
        paymentMethod: 'UNKNOWN',
        previousDebt: 0.0,
        remainingDebt: 0.0,
        notes: 'Error loading payment data',
        receivedBy: '',
        paymentDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'transactionId': transactionId,
    'customerId': customerId,
    'customerName': customerName,
    'paymentAmount': paymentAmount,
    'paymentMethod': paymentMethod,
    'previousDebt': previousDebt,
    'remainingDebt': remainingDebt,
    'notes': notes,
    'receivedBy': receivedBy,
    'paymentDate': Timestamp.fromDate(paymentDate),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}