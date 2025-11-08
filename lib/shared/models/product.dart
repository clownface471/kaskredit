import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'product.freezed.dart';
part 'product.g.dart';

// Helper function untuk konversi timestamp
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

@freezed
class Product with _$Product {
  const factory Product({
    // INI PERBAIKANNYA:
    // 1. Buat jadi nullable (String?)
    // 2. Kita kembali pakai 'includeFromJson: false' sesuai saran linter.
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
    // Logika ini sekarang aman:
    // 1. Product.fromJson(data) akan membuat produk dengan id = null.
    // 2. .copyWith(id: doc.id) akan mengisi id-nya dari Firestore.
    return Product.fromJson(data).copyWith(id: doc.id);
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}