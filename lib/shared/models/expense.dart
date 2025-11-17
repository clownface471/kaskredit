import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'expense.freezed.dart'; // Akan dibuat
part 'expense.g.dart';     // Akan dibuat

// Helper function untuk konversi timestamp
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

@freezed
class Expense with _$Expense {
  const factory Expense({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    required String userId,
    required String description, // Misal: "Bayar Listrik"
    required double amount,      // Misal: 500000
    String? category,           // Misal: "Operasional"
    String? notes,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime expenseDate, // Tanggal pengeluaran
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
  }) = _Expense;

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense.fromJson(data).copyWith(id: doc.id);
  }

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}