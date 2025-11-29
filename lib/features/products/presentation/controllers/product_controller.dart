import 'package:flutter/material.dart'; // TAMBAHKAN INI
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/features/products/data/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _repository = ProductRepository();
  
  // Reactive state
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Computed property untuk filtered products
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

  void loadProducts() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;
    
    _repository.getProducts(userId).listen(
      (productList) {
        products.value = productList;
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat produk: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
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
    // Show confirmation dialog
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