import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/reports/data/report_repository.dart';
import 'package:kaskredit_1/shared/models/sales_report.dart';

part 'report_provider.g.dart'; // Akan dibuat

// --- Model untuk State Notifier ---
// Kita butuh ini untuk menyimpan data laporan DAN status loading/error
@riverpod
class SalesReportNotifier extends _$SalesReportNotifier {
  
  @override
  // State awal adalah 'idle' (belum ada data)
  AsyncValue<SalesReport?> build() {
    return const AsyncValue.data(null);
  }

  // Fungsi untuk mengambil laporan
  Future<void> generateReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Set state ke loading
    state = const AsyncValue.loading();
    
    // 2. Ambil data
    final repo = ref.read(reportRepositoryProvider);
    final userId = ref.read(currentUserProvider).value?.id;

    if (userId == null) {
      state = AsyncValue.error("User tidak login", StackTrace.current);
      return;
    }

    // 3. Gunakan AsyncValue.guard untuk menangkap error
    state = await AsyncValue.guard(() async {
      return repo.generateSalesReport(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    });
  }
}

// --- Provider untuk menyimpan rentang tanggal ---
// (Ini agar tanggal tetap tersimpan saat kita keluar-masuk halaman)
final reportDateRangeProvider = StateProvider<DateTimeRange?>((ref) {
  // Default: null (belum dipilih)
  return null;
});