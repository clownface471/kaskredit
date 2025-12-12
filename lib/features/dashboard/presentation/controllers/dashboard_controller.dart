import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/features/dashboard/data/dashboard_repository.dart';
import 'package:kaskredit_1/shared/models/dashboard_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class DailySalesData {
  final DateTime date;
  final double sales;
  final double profit;
  
  DailySalesData({
    required this.date,
    required this.sales,
    required this.profit,
  });
}

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final Rx<DashboardStats?> stats = Rx<DashboardStats?>(null);
  final RxBool isLoading = false.obs;
  
  final RxList<DailySalesData> weeklyData = <DailySalesData>[].obs;
  final RxBool isLoadingChart = false.obs;
  
  Timer? _refreshTimer; // Auto refresh timer

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadWeeklyChartData();
    
    // Auto refresh setiap 5 menit
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => refreshData(),
    );
  }

  @override
  void onClose() {
    _refreshTimer?.cancel(); // Clean up timer
    super.onClose();
  }

  Future<void> loadStats() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final result = await _repository.getDashboardStats(userId);
      stats.value = result;
    } catch (e) {
      print("Error loading dashboard: $e");
      Get.snackbar(
        'Error',
        'Gagal memuat dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWeeklyChartData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      isLoadingChart.value = true;
      
      final now = DateTime.now();
      final sevenDaysAgo = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 6));
      
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('transactionDate', isGreaterThanOrEqualTo: sevenDaysAgo)
          .where('transactionDate', isLessThanOrEqualTo: DateTime.now())
          .get();
      
      Map<String, DailySalesData> dailyMap = {};
      
      for (int i = 0; i < 7; i++) {
        final date = sevenDaysAgo.add(Duration(days: i));
        final dateKey = '${date.year}-${date.month}-${date.day}';
        dailyMap[dateKey] = DailySalesData(
          date: date,
          sales: 0,
          profit: 0,
        );
      }
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final timestamp = data['transactionDate'] as Timestamp;
          final date = timestamp.toDate();
          final dateKey = '${date.year}-${date.month}-${date.day}';
          
          final sales = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final profit = (data['totalProfit'] as num?)?.toDouble() ?? 0.0;
          
          if (dailyMap.containsKey(dateKey)) {
            final existing = dailyMap[dateKey]!;
            dailyMap[dateKey] = DailySalesData(
              date: existing.date,
              sales: existing.sales + sales,
              profit: existing.profit + profit,
            );
          }
        } catch (e) {
          print('Error parsing transaction: $e');
        }
      }
      
      final List<DailySalesData> chartData = dailyMap.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      
      weeklyData.value = chartData;
    } catch (e) {
      print("Error loading chart data: $e");
    } finally {
      isLoadingChart.value = false;
    }
  }
  
  Future<void> refreshData() async {
    await Future.wait([
      loadStats(),
      loadWeeklyChartData(),
    ]);
  }
  
  double get maxSalesValue {
    if (weeklyData.isEmpty) return 0;
    return weeklyData.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
  }
  
  double get weekTotalSales {
    return weeklyData.fold(0.0, (sum, day) => sum + day.sales);
  }
  
  double get weekTotalProfit {
    return weeklyData.fold(0.0, (sum, day) => sum + day.profit);
  }
  
  double get avgDailySales {
    if (weeklyData.isEmpty) return 0;
    return weekTotalSales / weeklyData.length;
  }
}