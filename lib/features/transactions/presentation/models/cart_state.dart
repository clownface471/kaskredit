import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/shared/models/transaction.dart'; // Untuk Enum

part 'cart_state.freezed.dart'; // Akan dibuat

// --- Sub-model untuk item di keranjang ---
@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required Product product,
    required int quantity,
  }) = _CartItem;

  const CartItem._(); // Konstruktor private untuk custom getter

  // Helper untuk hitung subtotal
  double get subtotal => product.sellingPrice * quantity;
}

// --- Model utama untuk state keranjang ---
@freezed
class CartState with _$CartState {
  const factory CartState({
    @Default([]) List<CartItem> items,
    @Default(PaymentType.CASH) PaymentType paymentType,
    Customer? selectedCustomer,
    DateTime? dueDate,
    String? notes,
  }) = _CartState;

  const CartState._(); // Konstruktor private untuk custom getter

  // Helper untuk hitung total
  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  // Helper untuk hitung profit
  double get totalProfit => items.fold(
      0,
      (sum, item) =>
          sum + (item.product.sellingPrice - item.product.capitalPrice) * item.quantity);
}