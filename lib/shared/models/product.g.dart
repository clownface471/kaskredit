// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      userId: json['userId'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      capitalPrice: (json['capitalPrice'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      minStock: (json['minStock'] as num?)?.toInt() ?? 5,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _dateTimeFromTimestamp(json['createdAt'] as Timestamp),
      updatedAt: _dateTimeFromTimestamp(json['updatedAt'] as Timestamp),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'sku': instance.sku,
      'sellingPrice': instance.sellingPrice,
      'capitalPrice': instance.capitalPrice,
      'stock': instance.stock,
      'minStock': instance.minStock,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'isActive': instance.isActive,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'updatedAt': _dateTimeToTimestamp(instance.updatedAt),
    };
