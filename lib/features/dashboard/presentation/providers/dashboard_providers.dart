import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. TAMBAHKAN IMPORT INI
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 2. PERBAIKI SEMUA IMPORT DI BAWAH INI MENJADI RELATIVE
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/dashboard_repository.dart';
import '../../../../shared/models/dashboard_stats.dart';

part 'dashboard_providers.g.dart'; // File ini akan dibuat

@riverpod
// 3. GANTI 'DashboardStatsRef' MENJADI 'Ref'
Future<DashboardStats> dashboardStats(Ref ref) async {
  
  final userId = ref.watch(currentUserProvider).value?.id;

  if (userId == null) {
    throw Exception("User tidak login.");
  }

  final repo = ref.watch(dashboardRepositoryProvider);
  
  return repo.getDashboardStats(userId);
}