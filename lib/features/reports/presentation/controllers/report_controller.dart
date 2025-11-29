import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/features/reports/data/report_repository.dart';
import 'package:kaskredit_1/shared/models/sales_report.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';

class ReportController extends GetxController {
  final ReportRepository _repository = ReportRepository();
  
  // State
  final Rx<SalesReport?> report = Rx<SalesReport?>(null);
  final Rx<DateTimeRange?> selectedRange = Rx<DateTimeRange?>(null);
  final RxBool isLoading = false.obs;

  Future<void> generateReport(DateTime startDate, DateTime endDate) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      GetXUtils.showError("User tidak login");
      return;
    }

    isLoading.value = true;
    selectedRange.value = DateTimeRange(start: startDate, end: endDate);

    try {
      final result = await _repository.generateSalesReport(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      report.value = result;
    } catch (e) {
      GetXUtils.showError("Gagal membuat laporan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}