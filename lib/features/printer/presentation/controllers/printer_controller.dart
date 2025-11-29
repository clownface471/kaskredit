import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaskredit_1/features/printer/data/printer_service.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';

class PrinterController extends GetxController {
  final PrinterService _service = PrinterService();
  
  // State
  final RxnString printerIp = RxnString();
  final RxBool autoPrint = false.obs;
  final RxString footerNote = ''.obs;
  final RxBool isScanning = false.obs;
  final RxList<String> foundPrinters = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    printerIp.value = prefs.getString('printer_ip');
    autoPrint.value = prefs.getBool('auto_print') ?? false;
    footerNote.value = prefs.getString('footer_note') ?? 'Terima kasih atas kunjungan Anda';
  }

  Future<void> saveSettings({String? ip, String? note}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (ip != null && ip.isNotEmpty) {
      await prefs.setString('printer_ip', ip);
      printerIp.value = ip;
    }
    
    if (note != null && note.isNotEmpty) {
      await prefs.setString('footer_note', note);
      footerNote.value = note;
    }
    
    GetXUtils.showSuccess("Pengaturan tersimpan");
  }

  Future<void> toggleAutoPrint(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_print', value);
    autoPrint.value = value;
  }

  Future<void> scanPrinters() async {
    isScanning.value = true;
    foundPrinters.clear();
    
    try {
      final results = await _service.scanPrinters();
      foundPrinters.assignAll(results);
      if (results.isEmpty) {
        Get.snackbar("Info", "Tidak ditemukan printer di jaringan lokal", 
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      }
    } catch (e) {
      GetXUtils.showError("Gagal scan: $e");
    } finally {
      isScanning.value = false;
    }
  }
}