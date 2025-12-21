// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      transactionId: json['transactionId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      paymentAmount: (json['paymentAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      previousDebt: (json['previousDebt'] as num).toDouble(),
      remainingDebt: (json['remainingDebt'] as num).toDouble(),
      notes: json['notes'] as String?,
      receivedBy: json['receivedBy'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'transactionId': instance.transactionId,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'paymentAmount': instance.paymentAmount,
      'paymentMethod': instance.paymentMethod,
      'previousDebt': instance.previousDebt,
      'remainingDebt': instance.remainingDebt,
      'notes': instance.notes,
      'receivedBy': instance.receivedBy,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
