import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/features/dashboard/data/dashboard_repository.dart';
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';

class DashboardController extends GetxController {
  // Kita panggil Repository langsung (pastikan DashboardRepository tidak pakai 'ref')
  final DashboardRepository _repository = DashboardRepository();
  
  // State Reactive
  final Rx<DashboardStats?> stats = Rx<DashboardStats?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final result = await _repository.getDashboardStats(userId);
      stats.value = result;
    } catch (e) {
      // Error handling diam atau snackbar
      print("Error loading dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fungsi untuk refresh (bisa dipanggil saat pull-to-refresh)
  Future<void> refreshData() async {
    await loadStats();
  }
}