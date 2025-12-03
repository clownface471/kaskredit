import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/features/customers/data/customer_repository.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';

enum CustomerFilter { all, withDebt, noDebt }

class CustomerController extends GetxController {
  final CustomerRepository _repository = CustomerRepository();
  
  // Reactive state
  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<CustomerFilter> currentFilter = CustomerFilter.all.obs;
  
  // Computed property untuk filtered customers
  List<Customer> get filteredCustomers {
    var result = customers.toList();
    
    // Apply filter
    switch (currentFilter.value) {
      case CustomerFilter.withDebt:
        result = result.where((c) => c.totalDebt > 0).toList();
        break;
      case CustomerFilter.noDebt:
        result = result.where((c) => c.totalDebt == 0).toList();
        break;
      case CustomerFilter.all:
      default:
        break;
    }
    
    // Apply search
    if (searchQuery.isNotEmpty) {
      result = result.where((customer) => 
          customer.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (customer.phoneNumber?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    return result;
  }

  // Stats
  int get totalCustomers => customers.length;
  int get debtorsCount => customers.where((c) => c.totalDebt > 0).length;
  double get totalDebt => customers.fold(0.0, (sum, c) => sum + c.totalDebt);

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
        GetXUtils.showError('Gagal memuat pelanggan: $error');
      },
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setFilter(CustomerFilter filter) {
    currentFilter.value = filter;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      isLoading.value = true;
      await _repository.addCustomer(customer);
      
      Get.back();
      GetXUtils.showSuccess('Pelanggan berhasil ditambahkan');
    } catch (e) {
      GetXUtils.showError('Gagal menambah pelanggan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      isLoading.value = true;
      await _repository.updateCustomer(customer);
      
      Get.back();
      GetXUtils.showSuccess('Pelanggan berhasil diupdate');
    } catch (e) {
      GetXUtils.showError('Gagal mengupdate pelanggan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCustomer(Customer customer) async {
    // Cek apakah customer masih punya utang
    if (customer.totalDebt > 0) {
      GetXUtils.showWarning(
        'Tidak dapat menghapus pelanggan yang masih memiliki utang',
        title: 'Tidak Bisa Dihapus',
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await GetXUtils.showConfirmDialog(
      title: 'Konfirmasi Hapus',
      message: 'Yakin ingin menghapus pelanggan "${customer.name}"?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
    );

    if (!confirmed) return;

    try {
      isLoading.value = true;
      await _repository.deleteCustomer(customer.id!);
      
      Get.back();
      GetXUtils.showSuccess('Pelanggan berhasil dihapus');
    } catch (e) {
      GetXUtils.showError('Gagal menghapus pelanggan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}