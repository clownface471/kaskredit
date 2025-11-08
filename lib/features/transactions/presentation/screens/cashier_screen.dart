import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/customers/presentation/providers/customer_providers.dart';
import 'package:kaskredit_1/features/products/presentation/providers/product_providers.dart';
import 'package:kaskredit_1/features/transactions/presentation/models/cart_state.dart';
import 'package:kaskredit_1/features/transactions/presentation/providers/cart_provider.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/product.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/features/transactions/data/transaction_repository.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onProductTap(Product product) {
    ref.read(cartProvider.notifier).addItem(product);
    // Kosongkan search bar setelah menambah
    _searchController.clear();
    // Tutup keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Tonton state keranjang
    final cartState = ref.watch(cartProvider);
    // Tonton provider pencarian produk
    final searchResults = ref.watch(productSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir"),
        actions: [
          // Tombol Reset Keranjang
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => ref.read(cartProvider.notifier).clear(),
          )
        ],
      ),
      body: Column(
        children: [
          // --- 1. SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Cari produk...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // --- 2. HASIL SEARCH ATAU LIST KERANJANG ---
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildCartView(cartState) // Tampilkan Keranjang
                : _buildSearchView(searchResults), // Tampilkan Hasil Search
          ),

          // --- 3. SUMMARY & PAYMENT ---
          _buildSummary(cartState),
        ],
      ),
    );
  }

  // Widget untuk menampilkan keranjang
  Widget _buildCartView(CartState cartState) {
    if (cartState.items.isEmpty) {
      return const Center(child: Text("Keranjang kosong. Cari produk untuk ditambahkan."));
    }
    
    // Sesuai blueprint [cite: 345]
    return ListView.separated(
      itemCount: cartState.items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = cartState.items[index];
        return ListTile(
          title: Text(item.product.name),
          subtitle: Text("Rp ${item.product.sellingPrice} x ${item.quantity}"),
          trailing: Text(
            "Rp ${item.subtotal}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // Tampilkan dialog untuk update/hapus
            _showUpdateQuantityDialog(item);
          },
        );
      },
    );
  }

  // Widget untuk menampilkan hasil pencarian
  Widget _buildSearchView(AsyncValue<List<Product>> searchResults) {
    return searchResults.when(
      data: (products) {
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
              trailing: Text("Rp ${product.sellingPrice}"),
              onTap: () => _onProductTap(product),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  // Widget untuk summary di bagian bawah
  Widget _buildSummary(CartState cartState) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TOTAL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  "Rp ${cartState.totalAmount.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Tipe Pembayaran (Sesuai blueprint [cite: 331-333])
            Row(
              children: [
                const Text("Bayar:"),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text("Tunai"),
                  selected: cartState.paymentType == PaymentType.CASH,
                  onSelected: (_) => ref.read(cartProvider.notifier).setPaymentType(PaymentType.CASH),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("Kredit"),
                  selected: cartState.paymentType == PaymentType.CREDIT,
                  onSelected: (_) => ref.read(cartProvider.notifier).setPaymentType(PaymentType.CREDIT),
                ),
              ],
            ),
            
            // Pilihan Pelanggan (jika kredit)
            if (cartState.paymentType == PaymentType.CREDIT)
              _buildCustomerSelector(), // Buat jadi widget terpisah
            
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
                // (Disable jika keranjang kosong ATAU jika kredit tapi pelanggan blm dipilih)
                onPressed: (cartState.items.isEmpty || (cartState.paymentType == PaymentType.CREDIT && cartState.selectedCustomer == null))
                  ? null 
                  : _checkout,
                child: const Text("CHECKOUT", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk dropdown pelanggan
  Widget _buildCustomerSelector() {
    final customersAsync = ref.watch(customersProvider);
    final selectedCustomer = ref.watch(cartProvider).selectedCustomer;

    return customersAsync.when(
      data: (customers) => DropdownButtonFormField<Customer>(
        value: selectedCustomer,
        hint: const Text("Pilih Pelanggan... (Wajib)"),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.person)),
        items: customers.map((customer) {
          return DropdownMenuItem(
            value: customer,
            child: Text(customer.name),
          );
        }).toList(),
        onChanged: (customer) {
          ref.read(cartProvider.notifier).selectCustomer(customer);
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, s) => Text("Error memuat pelanggan: $e"),
    );
  }

  // --- LOGIKA DIALOG DAN CHECKOUT ---

  // Dialog untuk update jumlah
  void _showUpdateQuantityDialog(CartItem item) {
    final qtyController = TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.product.name),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Jumlah"),
        ),
        actions: [
          // Tombol Hapus
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(item.product.id!);
              Navigator.of(ctx).pop();
            },
            child: const Text("Hapus dari Keranjang"),
          ),
          // Tombol Update
          TextButton(
            onPressed: () {
              final newQty = int.tryParse(qtyController.text) ?? 0;
              ref.read(cartProvider.notifier).updateQuantity(item.product.id!, newQty);
              Navigator.of(ctx).pop();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // Fungsi Checkout
  Future<void> _checkout() async {
    final cartState = ref.read(cartProvider);

    // Dapatkan User ID
    final userId = ref.read(currentUserProvider).value?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User tidak login.")),
      );
      return;
    }

    // Tampilkan loading (jika perlu)
    // setState(() => _isLoading = true); // (Tambahkan state _isLoading jika mau)

    try {
      // Panggil repository
      await ref.read(transactionRepositoryProvider).createTransaction(cartState, userId);

      // Bersihkan keranjang
      ref.read(cartProvider.notifier).clear();

      // Tampilkan notifikasi sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaksi berhasil disimpan!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Tampilkan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan transaksi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Hilangkan loading
      // if (mounted) setState(() => _isLoading = false);
    }
  }
}