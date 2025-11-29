import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:kaskredit_1/features/customers/presentation/controllers/customer_controller.dart';
import 'package:kaskredit_1/features/products/presentation/controllers/product_controller.dart';
import 'package:kaskredit_1/features/transactions/presentation/controllers/cart_controller.dart';
import 'package:kaskredit_1/features/transactions/presentation/models/cart_state.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/shared/models/transaction.dart'; 

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  // Controller Text Field
  final _searchController = TextEditingController();
  
  // Inject Controllers
  // Kita pakai Get.put agar controller dibuat jika belum ada
  final CartController cartController = Get.put(CartController());
  final ProductController productController = Get.put(ProductController());
  final CustomerController customerController = Get.put(CustomerController());

  @override
  void initState() {
    super.initState();
    // Reset search query saat masuk halaman
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
          )
        ],
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR
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

          // 2. LIST AREA (Keranjang vs Hasil Pencarian)
          Expanded(
            child: Obx(() {
              // Jika user sedang mengetik di search bar, tampilkan hasil pencarian produk
              if (productController.searchQuery.isNotEmpty) {
                return _buildSearchResults();
              }
              
              // Jika tidak, tampilkan isi keranjang
              return _buildCartView();
            }),
          ),

          // 3. SUMMARY & CHECKOUT
          _buildSummary(),
        ],
      ),
    );
  }

  // --- WIDGETS ---

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
            // Opsional: Clear search setelah add
            // _searchController.clear();
            // productController.updateSearchQuery('');
            // FocusScope.of(context).unfocus();
          },
        );
      },
    );
  }

  Widget _buildCartView() {
    // Akses state dari CartController
    final items = cartController.items;

    if (items.isEmpty) {
      return const Center(child: Text("Keranjang kosong. Cari produk untuk ditambahkan."));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.product.name),
          subtitle: Text("${Formatters.currency.format(item.product.sellingPrice)} x ${item.quantity}"),
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
        // Kita bungkus dengan Obx agar UI update saat cart berubah
        final total = cartController.totalAmount;
        final type = cartController.paymentType;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    Formatters.currency.format(total),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Payment Type Selector
              Row(
                children: [
                  const Text("Bayar:"),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text("Tunai"),
                    selected: type == PaymentType.CASH,
                    onSelected: (_) => cartController.setPaymentType(PaymentType.CASH),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Kredit"),
                    selected: type == PaymentType.CREDIT,
                    onSelected: (_) => cartController.setPaymentType(PaymentType.CREDIT),
                  ),
                ],
              ),

              // Form Kredit (Jika dipilih)
              if (type == PaymentType.CREDIT) ...[
                const SizedBox(height: 16),
                _buildCustomerDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildNumberInput("DP (Rp)", (val) => cartController.setDownPayment(val))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberInput("Bunga (%)", (val) => cartController.setInterestRate(val))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberInput("Tenor (Bln)", (val) => cartController.setTenor(val))),
                  ],
                ),
                const Divider(height: 24),
                _InfoRow(label: "Total + Bunga:", value: Formatters.currency.format(cartController.totalWithInterest)),
                _InfoRow(label: "Sisa Utang:", value: Formatters.currency.format(cartController.remainingDebt)),
                _InfoRow(label: "Cicilan / Bulan:", value: Formatters.currency.format(cartController.monthlyInstallment), isBold: true),
              ],

              const SizedBox(height: 16),

              // Tombol Checkout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white
                  ),
                  onPressed: cartController.isLoading.value ? null : _processCheckout,
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
    // Kita gunakan data dari CustomerController
    // Pastikan CustomerController sudah di-load datanya
    return Obx(() {
      final customers = customerController.customers;
      return DropdownButtonFormField<Customer>(
        value: cartController.selectedCustomer, // Nilai terpilih
        hint: const Text("Pilih Pelanggan... (Wajib)"),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
        items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
        onChanged: (val) => cartController.selectCustomer(val),
      );
    });
  }

  Widget _buildNumberInput(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // atau allow decimal untuk bunga
      onChanged: onChanged,
    );
  }

  // --- ACTIONS ---

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
      // Jika berhasil, tampilkan dialog sukses dan opsi print
      Get.defaultDialog(
        title: "Transaksi Berhasil",
        middleText: "No: ${transaction.transactionNumber}\nTotal: ${Formatters.currency.format(transaction.totalAmount)}",
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Tutup dialog
            child: const Text("Tutup"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text("Cetak Struk"),
            onPressed: () {
              Get.back(); // Tutup dialog dulu
              // TODO: Implementasi Print Logic di sini (memanggil PrinterService)
              Get.snackbar("Info", "Fitur print akan segera hadir");
            },
          ),
        ],
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _InfoRow({required this.label, required this.value, this.isBold = false});

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