// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      userId: json['userId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      expenseDate: _dateTimeFromTimestamp(json['expenseDate'] as Timestamp),
      createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'description': instance.description,
      'amount': instance.amount,
      'category': instance.category,
      'notes': instance.notes,
      'expenseDate': _dateTimeToTimestamp(instance.expenseDate),
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
    };
