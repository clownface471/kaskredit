// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStatsImpl _$$DailyStatsImplFromJson(Map<String, dynamic> json) =>
    _$DailyStatsImpl(
      date: _dateTimeFromTimestamp(json['date'] as Timestamp),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
    );

Map<String, dynamic> _$$DailyStatsImplToJson(_$DailyStatsImpl instance) =>
    <String, dynamic>{
      'date': _dateTimeToTimestamp(instance.date),
      'totalSales': instance.totalSales,
      'totalProfit': instance.totalProfit,
    };

_$ProductStatsImpl _$$ProductStatsImplFromJson(Map<String, dynamic> json) =>
    _$ProductStatsImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantitySold: (json['quantitySold'] as num).toInt(),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
    );

Map<String, dynamic> _$$ProductStatsImplToJson(_$ProductStatsImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'quantitySold': instance.quantitySold,
      'totalSales': instance.totalSales,
      'totalProfit': instance.totalProfit,
    };

_$SalesReportImpl _$$SalesReportImplFromJson(Map<String, dynamic> json) =>
    _$SalesReportImpl(
      startDate: _dateTimeFromTimestamp(json['startDate'] as Timestamp),
      endDate: _dateTimeFromTimestamp(json['endDate'] as Timestamp),
      totalSales: (json['totalSales'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      cashSales: (json['cashSales'] as num).toDouble(),
      creditSales: (json['creditSales'] as num).toDouble(),
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>)
          .map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      topProducts: (json['topProducts'] as List<dynamic>)
          .map((e) => ProductStats.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SalesReportImplToJson(_$SalesReportImpl instance) =>
    <String, dynamic>{
      'startDate': _dateTimeToTimestamp(instance.startDate),
      'endDate': _dateTimeToTimestamp(instance.endDate),
      'totalSales': instance.totalSales,
      'totalProfit': instance.totalProfit,
      'totalTransactions': instance.totalTransactions,
      'cashSales': instance.cashSales,
      'creditSales': instance.creditSales,
      'dailyBreakdown': instance.dailyBreakdown.map((e) => e.toJson()).toList(),
      'topProducts': instance.topProducts.map((e) => e.toJson()).toList(),
    };
