import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart'; // Akan dibuat
part 'dashboard_stats.g.dart';     // Akan dibuat

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    // Statistik hari ini
    required double todaySales,
    required double todayProfit,
    required int todayTransactions,
    required double todayNewDebt,
    
    // Statistik keseluruhan
    required double totalOutstandingDebt,
    required int totalDebtors, // Jumlah pelanggan yg punya utang
    
    // Statistik inventaris
    required int lowStockProducts,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}