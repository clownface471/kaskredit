import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:kaskredit_1/features/transactions/presentation/models/cart_state.dart';
import 'package:kaskredit_1/features/transactions/data/transaction_repository.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';

class CartController extends GetxController {
  final TransactionRepository _repository = TransactionRepository();
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  final Rx<CartState> state = const CartState().obs;
  final RxBool isLoading = false.obs;

  // Getters
  List<CartItem> get items => state.value.items;
  double get totalAmount => state.value.totalAmount;
  PaymentType get paymentType => state.value.paymentType;
  Customer? get selectedCustomer => state.value.selectedCustomer;
  double get totalWithInterest => state.value.totalWithInterest;
  double get remainingDebt => state.value.remainingDebt;
  double get monthlyInstallment => state.value.monthlyInstallment;

  // === ADD ITEM WITH VALIDATION ===
  void addItem(Product product, {int quantity = 1}) {
    if (product.stock <= 0) {
      GetXUtils.showError("Stok produk ini sudah habis", title: "Stok Habis");
      return;
    }

    final currentItems = [...state.value.items];
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final oldItem = currentItems[existingIndex];
      final newQuantity = oldItem.quantity + quantity;

      if (newQuantity > product.stock) {
        GetXUtils.showError("Sisa stok hanya: ${product.stock}", title: "Stok Terbatas");
        return;
      }
      
      currentItems[existingIndex] = oldItem.copyWith(quantity: newQuantity);
    } else {
      if (quantity > product.stock) {
        GetXUtils.showError("Sisa stok hanya: ${product.stock}", title: "Stok Terbatas");
        return;
      }
      currentItems.add(CartItem(product: product, quantity: quantity));
    }
    
    state.value = state.value.copyWith(items: currentItems);
    
    Get.snackbar(
      "Berhasil", 
      "${product.name} ditambahkan ke keranjang", 
      duration: const Duration(seconds: 1),
      animationDuration: const Duration(milliseconds: 300),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.2),
    );
  }

  void removeItem(String productId) {
    final currentItems = state.value.items.where((item) => item.product.id != productId).toList();
    state.value = state.value.copyWith(items: currentItems);
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final currentItems = state.value.items.map((item) {
      if (item.product.id == productId) {
        if (newQuantity > item.product.stock) {
          GetXUtils.showError("Stok tidak mencukupi");
          return item;
        }
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state.value = state.value.copyWith(items: currentItems);
  }

  void setPaymentType(PaymentType type) {
    if (type == PaymentType.CASH) {
      state.value = state.value.copyWith(
        paymentType: type, 
        selectedCustomer: null, 
        dueDate: null,
        downPayment: 0.0,
        interestRate: 0.0,
        tenor: 0,
      );
    } else {
      state.value = state.value.copyWith(paymentType: type);
    }
  }

  void selectCustomer(Customer? customer) {
    state.value = state.value.copyWith(selectedCustomer: customer);
  }
  
  void setDownPayment(String value) {
    final dp = double.tryParse(value) ?? 0.0;
    state.value = state.value.copyWith(downPayment: dp);
  }
  
  void setInterestRate(String value) {
    final rate = double.tryParse(value) ?? 0.0;
    state.value = state.value.copyWith(interestRate: rate);
  }
  
  void setTenor(String value) {
    final months = int.tryParse(value) ?? 0;
    state.value = state.value.copyWith(tenor: months);
  }

  void clear() {
    state.value = const CartState();
  }

  // === CHECKOUT WITH REALTIME STOCK VALIDATION ===
  Future<Transaction?> checkout() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      GetXUtils.showError("User tidak login");
      return null;
    }

    if (items.isEmpty) {
      GetXUtils.showError("Keranjang kosong");
      return null;
    }
    
    if (paymentType == PaymentType.CREDIT && selectedCustomer == null) {
      GetXUtils.showError("Pilih pelanggan untuk transaksi kredit");
      return null;
    }

    try {
      isLoading.value = true;
      
      // === VALIDASI STOK REAL-TIME ===
      await _validateStockAvailability();
      
      // === PROSES TRANSAKSI ===
      final transaction = await _repository.createTransaction(state.value, userId);
      
      clear();
      return transaction;
      
    } on StockValidationException catch (e) {
      GetXUtils.showError(e.message, title: "Stok Tidak Cukup");
      return null;
    } catch (e) {
      GetXUtils.showError("Gagal memproses transaksi: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Validasi stok real-time sebelum checkout
  Future<void> _validateStockAvailability() async {
    for (final item in items) {
      final productDoc = await _firestore
          .collection('products')
          .doc(item.product.id)
          .get();
      
      if (!productDoc.exists) {
        throw StockValidationException(
          "Produk '${item.product.name}' tidak ditemukan. "
          "Mungkin telah dihapus oleh user lain."
        );
      }
      
      final data = productDoc.data();
      final currentStock = data?['stock'] as int? ?? 0;
      
      if (currentStock < item.quantity) {
        throw StockValidationException(
          "Stok '${item.product.name}' tidak cukup!\n"
          "Diminta: ${item.quantity}, Tersisa: $currentStock"
        );
      }
    }
  }
}

/// Custom Exception untuk Stock Validation
class StockValidationException implements Exception {
  final String message;
  StockValidationException(this.message);
  
  @override
  String toString() => message;
}
