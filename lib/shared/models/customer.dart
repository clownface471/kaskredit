import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

@freezed
class Customer with _$Customer {
  const factory Customer({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    required String userId,
    required String name,
    String? phoneNumber,
    String? address,
    @Default(0.0) double totalDebt, 
    String? notes,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime updatedAt,
  }) = _Customer;

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // --- FIX CRASH SERVER TIMESTAMP ---
    if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
    if (data['updatedAt'] == null) data['updatedAt'] = Timestamp.now();
    // ----------------------------------

    return Customer.fromJson(data).copyWith(id: doc.id);
  }

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}