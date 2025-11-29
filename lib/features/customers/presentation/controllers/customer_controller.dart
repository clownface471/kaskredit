import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/features/customers/data/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository _repository = CustomerRepository();
  
  // Reactive state
  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Computed property untuk filtered customers
  List<Customer> get filteredCustomers {
    if (searchQuery.isEmpty) {
      return customers;
    }
    return customers
        .where((customer) => 
            customer.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (customer.phoneNumber?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  void loadCustomers() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;
    
    _repository.getCustomers(userId).listen(
      (customerList) {
        customers.value = customerList;
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat pelanggan: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
        );
      },
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      isLoading.value = true;
      await _repository.addCustomer(customer);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pelanggan berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambah pelanggan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      isLoading.value = true;
      await _repository.updateCustomer(customer);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pelanggan berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupdate pelanggan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCustomer(Customer customer) async {
    // Cek apakah customer masih punya utang
    if (customer.totalDebt > 0) {
      Get.snackbar(
        'Gagal',
        'Pelanggan ini masih memiliki utang',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus pelanggan "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;
      await _repository.deleteCustomer(customer.id!);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pelanggan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus pelanggan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
