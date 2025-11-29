import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/features/transactions/presentation/models/cart_state.dart';
import 'package:kaskredit_1/features/transactions/data/transaction_repository.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart'; 

class CartController extends GetxController {
  final TransactionRepository _repository = TransactionRepository();
  
  // State Reactive
  final Rx<CartState> state = const CartState().obs;
  final RxBool isLoading = false.obs;

  // --- Getters ---
  List<CartItem> get items => state.value.items;
  double get totalAmount => state.value.totalAmount;
  PaymentType get paymentType => state.value.paymentType;
  Customer? get selectedCustomer => state.value.selectedCustomer;
  
  double get totalWithInterest => state.value.totalWithInterest;
  double get remainingDebt => state.value.remainingDebt;
  double get monthlyInstallment => state.value.monthlyInstallment;

  // --- Actions ---

  void addItem(Product product, {int quantity = 1}) {
    // Validasi stok
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
    
    // Update state
    state.value = state.value.copyWith(items: currentItems);
    
    // PERBAIKAN DI SINI: Gunakan Get.snackbar dengan animationDuration eksplisit
    Get.snackbar(
      "Berhasil", 
      "${product.name} ditambahkan ke keranjang", 
      duration: const Duration(seconds: 1), // Naikkan sedikit durasinya (min 1 detik)
      animationDuration: const Duration(milliseconds: 300), // <-- TAMBAHAN PENTING
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
          return item; // Return item lama jika stok kurang
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
      final transaction = await _repository.createTransaction(state.value, userId);
      
      clear(); // Bersihkan keranjang setelah sukses
      // Kita tidak panggil showSuccess disini, karena UI (CashierScreen) akan handle dialog sukses
      return transaction;
    } catch (e) {
      GetXUtils.showError("Gagal memproses transaksi: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}