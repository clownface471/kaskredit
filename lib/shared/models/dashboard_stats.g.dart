// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      todaySales: (json['todaySales'] as num).toDouble(),
      todayProfit: (json['todayProfit'] as num).toDouble(),
      todayTransactions: (json['todayTransactions'] as num).toInt(),
      todayNewDebt: (json['todayNewDebt'] as num).toDouble(),
      totalOutstandingDebt: (json['totalOutstandingDebt'] as num).toDouble(),
      totalDebtors: (json['totalDebtors'] as num).toInt(),
      lowStockProducts: (json['lowStockProducts'] as num).toInt(),
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
  _$DashboardStatsImpl instance,
) => <String, dynamic>{
  'todaySales': instance.todaySales,
  'todayProfit': instance.todayProfit,
  'todayTransactions': instance.todayTransactions,
  'todayNewDebt': instance.todayNewDebt,
  'totalOutstandingDebt': instance.totalOutstandingDebt,
  'totalDebtors': instance.totalDebtors,
  'lowStockProducts': instance.lowStockProducts,
};
