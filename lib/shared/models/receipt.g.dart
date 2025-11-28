// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiptImpl _$$ReceiptImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptImpl(
      transaction: Transaction.fromJson(
        json['transaction'] as Map<String, dynamic>,
      ),
      shopName: json['shopName'] as String,
      shopAddress: json['shopAddress'] as String?,
      shopPhone: json['shopPhone'] as String?,
      footerNote: json['footerNote'] as String?,
    );

Map<String, dynamic> _$$ReceiptImplToJson(_$ReceiptImpl instance) =>
    <String, dynamic>{
      'transaction': instance.transaction.toJson(),
      'shopName': instance.shopName,
      'shopAddress': instance.shopAddress,
      'shopPhone': instance.shopPhone,
      'footerNote': instance.footerNote,
    };
