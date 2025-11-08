import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'transaction_item.freezed.dart';
part 'transaction_item.g.dart';

@freezed
class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    required String productId,
    required String productName, // Denormalized
    required int quantity,
    required double sellingPrice, // Denormalized
    required double capitalPrice, // Denormalized (untuk hitung profit)
    required double subtotal,
  }) = _TransactionItem;

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
}