// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      userId: json['userId'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp),
      updatedAt: _dateTimeFromTimestamp(json['updatedAt'] as Timestamp),
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'totalDebt': instance.totalDebt,
      'notes': instance.notes,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'updatedAt': _dateTimeToTimestamp(instance.updatedAt),
    };
