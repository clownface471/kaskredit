import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'sales_report.freezed.dart'; // Akan dibuat
part 'sales_report.g.dart';     // Akan dibuat

// Helper function untuk konversi timestamp
DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

// --- Model 1: Statistik Harian (untuk chart) ---
// Sesuai blueprint [cite: 1469]
@freezed
class DailyStats with _$DailyStats {
  const factory DailyStats({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime date,
    required double totalSales,
    required double totalProfit,
  }) = _DailyStats;

  factory DailyStats.fromJson(Map<String, dynamic> json) => _$DailyStatsFromJson(json);
}

// --- Model 2: Statistik Produk Terlaris ---
// Sesuai blueprint [cite: 1470]
@freezed
class ProductStats with _$ProductStats {
  const factory ProductStats({
    required String productId,
    required String productName,
    required int quantitySold,
    required double totalSales,
    required double totalProfit,
  }) = _ProductStats;

  factory ProductStats.fromJson(Map<String, dynamic> json) => _$ProductStatsFromJson(json);
}

// --- Model 3: Laporan Penjualan Utama (Main Report) ---
// Sesuai blueprint [cite: 1459-1471]
@freezed
class SalesReport with _$SalesReport {
  const factory SalesReport({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime startDate,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime endDate,
    
    required double totalSales,
    required double totalProfit,
    required int totalTransactions,
    required double cashSales,
    required double creditSales,
    
    required List<DailyStats> dailyBreakdown,
    required List<ProductStats> topProducts,
  }) = _SalesReport;

  factory SalesReport.fromJson(Map<String, dynamic> json) => _$SalesReportFromJson(json);
}