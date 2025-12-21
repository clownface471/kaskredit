// lib/features/transactions/presentation/screens/cashier_screen.dart
// FIXED VERSION - Update import dan print function

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:kaskredit_1/features/customers/presentation/controllers/customer_controller.dart';
import 'package:kaskredit_1/features/products/presentation/controllers/product_controller.dart';
import 'package:kaskredit_1/features/transactions/presentation/controllers/cart_controller.dart';
import 'package:kaskredit_1/features/transactions/presentation/models/cart_state.dart';
// GANTI IMPORT INI:
import 'package:kaskredit_1/features/printer/presentation/controllers/bluetooth_printer_controller.dart';
import 'package:kaskredit_1/features/settings/presentation/screens/settings_screen.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final _searchController = TextEditingController();

  final CartController cartController = Get.put(CartController());
  final ProductController productController = Get.put(ProductController());
  final CustomerController customerController = Get.put(CustomerController());
  // GANTI INI:
  final BluetoothPrinterController printerController = Get.put(
    BluetoothPrinterController(),
  );
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    productController.updateSearchQuery('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearCart(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Cari produk...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => productController.updateSearchQuery(val),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (productController.searchQuery.isNotEmpty) {
                return _buildSearchResults();
              }
              return _buildCartView();
            }),
          ),

          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final products = productController.filteredProducts;

    if (productController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return const Center(child: Text("Produk tidak ditemukan."));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text("Stok: ${product.stock}"),
          trailing: Text(Formatters.currency.format(product.sellingPrice)),
          onTap: () {
            cartController.addItem(product);
          },
        );
      },
    );
  }

  Widget _buildCartView() {
    final items = cartController.items;

    if (items.isEmpty) {
      return const Center(
        child: Text("Keranjang kosong. Cari produk untuk ditambahkan."),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.product.name),
          subtitle: Text(
            "${Formatters.currency.format(item.product.sellingPrice)} x ${item.quantity}",
          ),
          trailing: Text(
            Formatters.currency.format(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => _showUpdateQuantityDialog(item),
        );
      },
    );
  }

  Widget _buildSummary() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      child: Obx(() {
        final total = cartController.totalAmount;
        final type = cartController.paymentType;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    Formatters.currency.format(total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              Row(
                children: [
                  const Text("Bayar:"),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text("Tunai"),
                    selected: type == PaymentType.CASH,
                    onSelected: (_) =>
                        cartController.setPaymentType(PaymentType.CASH),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Kredit"),
                    selected: type == PaymentType.CREDIT,
                    onSelected: (_) =>
                        cartController.setPaymentType(PaymentType.CREDIT),
                  ),
                ],
              ),

              if (type == PaymentType.CREDIT) ...[
                const SizedBox(height: 16),
                _buildCustomerDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberInput(
                        "DP (Rp)",
                        (val) => cartController.setDownPayment(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNumberInput(
                        "Bunga (%)",
                        (val) => cartController.setInterestRate(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNumberInput(
                        "Tenor (Bln)",
                        (val) => cartController.setTenor(val),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _InfoRow(
                  label: "Total + Bunga:",
                  value: Formatters.currency.format(
                    cartController.totalWithInterest,
                  ),
                ),
                _InfoRow(
                  label: "Sisa Utang:",
                  value: Formatters.currency.format(
                    cartController.remainingDebt,
                  ),
                ),
                _InfoRow(
                  label: "Cicilan / Bulan:",
                  value: Formatters.currency.format(
                    cartController.monthlyInstallment,
                  ),
                  isBold: true,
                ),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: cartController.isLoading.value
                      ? null
                      : _processCheckout,
                  child: cartController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CHECKOUT", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCustomerDropdown() {
    return Obx(() {
      final customers = customerController.customers;

      Customer? selectedValue;
      if (cartController.selectedCustomer != null) {
        try {
          selectedValue = customers.firstWhere(
            (c) => c.id == cartController.selectedCustomer!.id,
          );
        } catch (_) {
          selectedValue = null;
        }
      }

      return DropdownButtonFormField<Customer>(
        value: selectedValue,
        hint: const Text("Pilih Pelanggan... (Wajib)"),
        isExpanded: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        items: customers
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text(c.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (val) => cartController.selectCustomer(val),
      );
    });
  }

  Widget _buildNumberInput(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
    );
  }

  void _confirmClearCart() {
    Get.defaultDialog(
      title: "Hapus Keranjang",
      middleText: "Yakin ingin mengosongkan keranjang?",
      textConfirm: "Ya",
      textCancel: "Tidak",
      confirmTextColor: Colors.white,
      onConfirm: () {
        cartController.clear();
        Get.back();
      },
    );
  }

  void _showUpdateQuantityDialog(CartItem item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    Get.defaultDialog(
      title: item.product.name,
      content: TextField(
        controller: qtyCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: "Jumlah"),
      ),
      textCancel: "Batal",
      cancelTextColor: Colors.black,
      actions: [
        TextButton(
          onPressed: () {
            cartController.removeItem(item.product.id!);
            Get.back();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("Hapus"),
        ),
        ElevatedButton(
          onPressed: () {
            final newQty = int.tryParse(qtyCtrl.text) ?? 0;
            cartController.updateQuantity(item.product.id!, newQty);
            Get.back();
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }

  Future<void> _processCheckout() async {
    final transaction = await cartController.checkout();

    if (transaction != null) {
      _showSuccessDialog(transaction);
    }
  }

  void _showSuccessDialog(Transaction transaction) {
    Get.defaultDialog(
      title: "✅ Transaksi Berhasil",
      barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "No: ${transaction.transactionNumber}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Total: ${Formatters.currency.format(transaction.totalAmount)}"),
          if (transaction.paymentType == PaymentType.CREDIT) ...[
            const SizedBox(height: 8),
            Text(
              "Sisa Utang: ${Formatters.currency.format(transaction.remainingDebt)}",
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Tutup")),
        Obx(() {
          final hasConnection = printerController.isConnected.value;
          return ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: Text(hasConnection ? "Cetak Struk" : "Setup Printer"),
            onPressed: () async {
              Get.back();

              if (!hasConnection) {
                Get.toNamed(AppRoutes.BLUETOOTH_PRINTER);
                return;
              }

              await _printReceipt(transaction);
            },
          );
        }),
      ],
    );
  }

  // FIXED PRINT FUNCTION:
  Future<void> _printReceipt(Transaction transaction) async {
    if (!printerController.isConnected.value) {
      Get.snackbar(
        "Error",
        "Printer belum terhubung",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String shopName = settingsController.shopName.value;
    if (shopName.isEmpty) shopName = "Toko Saya";

    // Langsung panggil printReceipt dari controller
    await printerController.printReceipt(
      transaction: transaction,
      shopName: shopName,
      shopAddress: settingsController.shopAddress.value,
      shopPhone: settingsController.shopPhone.value,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.blue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}