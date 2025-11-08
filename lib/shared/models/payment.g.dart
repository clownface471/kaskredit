// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
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
      paymentDate: _dateTimeFromTimestamp(json['paymentDate'] as Timestamp),
      createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
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
      'paymentDate': _dateTimeToTimestamp(instance.paymentDate),
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
    };
