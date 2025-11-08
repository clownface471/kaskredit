import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/features/transactions/presentation/models/cart_state.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/shared/models/transaction.dart'; // Untuk Enum

part 'cart_provider.g.dart';

// Ini adalah sintaks Notifier modern (menggantikan StateNotifier)
@Riverpod(keepAlive: true)
class Cart extends Notifier<CartState> {
  
  @override
  CartState build() {
    // Kembalikan state awal (keranjang kosong)
    return const CartState();
  }

  // --- Semua fungsi logika pindah ke sini ---

  void addItem(Product product, {int quantity = 1}) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedItems = [...state.items];
      final oldItem = updatedItems[existingIndex];
      final newQuantity = oldItem.quantity + quantity;

      if (newQuantity > product.stock) {
        // TODO: Tampilkan error "Stok tidak cukup"
        return;
      }
      
      updatedItems[existingIndex] = oldItem.copyWith(quantity: newQuantity);
      state = state.copyWith(items: updatedItems);
    } else {
      if (quantity > product.stock) {
        // TODO: Tampilkan error
        return;
      }
      state = state.copyWith(items: [
        ...state.items,
        CartItem(product: product, quantity: quantity),
      ]);
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        if (newQuantity > item.product.stock) {
          // TODO: Tampilkan error
          return item;
        }
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void setPaymentType(PaymentType type) {
    if (type == PaymentType.CASH) {
      // Jika tunai, hapus pelanggan
      state = state.copyWith(paymentType: type, selectedCustomer: null, dueDate: null);
    } else {
      state = state.copyWith(paymentType: type);
    }
  }

  void selectCustomer(Customer? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }
  
  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void clear() {
    state = const CartState();
  }
}