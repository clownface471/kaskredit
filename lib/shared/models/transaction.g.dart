// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      userId: json['userId'] as String,
      transactionNumber: json['transactionNumber'] as String,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
      paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['paymentStatus']),
      paymentType: $enumDecode(_$PaymentTypeEnumMap, json['paymentType']),
      downPayment: (json['downPayment'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      tenor: (json['tenor'] as num?)?.toInt() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      remainingDebt: (json['remainingDebt'] as num?)?.toDouble() ?? 0.0,
      transactionDate: _dateTimeFromTimestamp(
        json['transactionDate'] as Timestamp,
      ),
      dueDate: _nullableDateTimeFromTimestamp(json['dueDate'] as Timestamp?),
      notes: json['notes'] as String?,
      createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp),
      updatedAt: _dateTimeFromTimestamp(json['updatedAt'] as Timestamp),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'transactionNumber': instance.transactionNumber,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'totalAmount': instance.totalAmount,
      'totalProfit': instance.totalProfit,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'paymentType': _$PaymentTypeEnumMap[instance.paymentType]!,
      'downPayment': instance.downPayment,
      'interestRate': instance.interestRate,
      'tenor': instance.tenor,
      'paidAmount': instance.paidAmount,
      'remainingDebt': instance.remainingDebt,
      'transactionDate': _dateTimeToTimestamp(instance.transactionDate),
      'dueDate': _nullableDateTimeToTimestamp(instance.dueDate),
      'notes': instance.notes,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'updatedAt': _dateTimeToTimestamp(instance.updatedAt),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.PAID: 'PAID',
  PaymentStatus.DEBT: 'DEBT',
  PaymentStatus.PARTIAL: 'PARTIAL',
};

const _$PaymentTypeEnumMap = {
  PaymentType.CASH: 'CASH',
  PaymentType.CREDIT: 'CREDIT',
  PaymentType.TRANSFER: 'TRANSFER',
};
