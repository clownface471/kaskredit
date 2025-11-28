import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/shared/models/app_user.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

@freezed
class Receipt with _$Receipt {
  const factory Receipt({
    required Transaction transaction,
    required String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
}