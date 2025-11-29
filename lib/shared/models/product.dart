import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'product.freezed.dart';
part 'product.g.dart';

DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

@freezed
class Product with _$Product {
  const factory Product({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,

    required String userId,
    required String name,
    String? sku,
    required double sellingPrice,
    required double capitalPrice,
    required int stock,
    @Default(5) int minStock,
    String? imageUrl,
    String? category,
    @Default(true) bool isActive,
    
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime updatedAt,
  }) = _Product;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // --- FIX CRASH SERVER TIMESTAMP ---
    if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
    if (data['updatedAt'] == null) data['updatedAt'] = Timestamp.now();
    // ----------------------------------

    return Product.fromJson(data).copyWith(id: doc.id);
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}