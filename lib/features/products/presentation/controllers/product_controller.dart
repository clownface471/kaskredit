import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/features/products/data/product_repository.dart';
import 'dart:async';

class ProductController extends GetxController {
  final ProductRepository _repository = ProductRepository();
  
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  StreamSubscription? _productSubscription;
  
  List<Product> get filteredProducts {
    if (searchQuery.isEmpty) {
      return products;
    }
    return products
        .where((product) => 
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }

  void loadProducts() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      products.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    
    _productSubscription?.cancel();
    
    _productSubscription = _repository.getProducts(userId).listen(
      (productList) {
        products.value = productList;
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        products.clear();
        Get.snackbar(
          'Error',
          'Gagal memuat produk: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      cancelOnError: false,
    );
  }

  // FIX: Return Future untuk RefreshIndicator
  Future<void> refreshProducts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await _repository.getProducts(userId).first;
      products.value = snapshot;
    } catch (e) {
      Get.snackbar('Error', 'Gagal refresh produk: $e');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> addProduct(Product product) async {
    try {
      isLoading.value = true;
      await _repository.addProduct(product);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Produk berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambah produk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      isLoading.value = true;
      await _repository.updateProduct(product);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Produk berhasil diupdate',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupdate produk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus produk ini?'),
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
      await _repository.deleteProduct(productId);
      
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Produk berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus produk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}