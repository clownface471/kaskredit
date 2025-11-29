import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

@freezed
class Expense with _$Expense {
  const factory Expense({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    required String userId,
    required String description, 
    required double amount,      
    String? category,           
    String? notes,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime expenseDate, 
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
  }) = _Expense;

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // --- FIX CRASH SERVER TIMESTAMP ---
    if (data['expenseDate'] == null) data['expenseDate'] = Timestamp.now();
    if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
    // ----------------------------------

    return Expense.fromJson(data).copyWith(id: doc.id);
  }

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}