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
import 'package:flutter/services.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:kaskredit_1/features/printer/data/printer_service.dart';
import 'package:kaskredit_1/features/printer/presentation/providers/printer_settings_provider.dart';

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
    try {
      ref.read(cartProvider.notifier).addItem(product);
      _searchController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
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
        // Ubah jadi ListView agar bisa di-scroll saat keyboard muncul
        child: ListView(
          shrinkWrap: true, // Agar pas dengan konten
          children: [
            // --- 1. Total ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TOTAL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  Formatters.currency.format(cartState.totalAmount),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // --- 2. Tipe Pembayaran ---
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
            
            // --- 3. FORM KREDIT (Baru) ---
            // Muncul jika tipe-nya KREDIT
            if (cartState.paymentType == PaymentType.CREDIT) ...[
              const SizedBox(height: 16),
              _buildCustomerSelector(), // Pilihan Pelanggan
              const SizedBox(height: 16),
              // Form DP, Bunga, Tenor
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "DP (Rp)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => ref.read(cartProvider.notifier).setDownPayment(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "Bunga (%)", border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => ref.read(cartProvider.notifier).setInterestRate(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "Tenor (Bln)", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => ref.read(cartProvider.notifier).setTenor(value),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Info Kalkulasi
              _InfoRow(label: "Total + Bunga:", value: Formatters.currency.format(cartState.totalWithInterest)),
              _InfoRow(label: "Sisa Utang:", value: Formatters.currency.format(cartState.remainingDebt)),
              _InfoRow(
                label: "Cicilan / Bulan:",
                value: Formatters.currency.format(cartState.monthlyInstallment),
                isBold: true,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // --- 4. Tombol Checkout ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white
                ),
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
              try {
                final newQty = int.tryParse(qtyController.text) ?? 0;
                ref.read(cartProvider.notifier).updateQuantity(item.product.id!, newQty);
                Navigator.of(ctx).pop();
              } catch (e) {
                Navigator.of(ctx).pop(); 
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
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

  final userId = ref.read(currentUserProvider).value?.id;
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error: User tidak login.")),
    );
    return;
  }

  try {
    // 1. Simpan transaksi
    await ref.read(transactionRepositoryProvider).createTransaction(cartState, userId);

    // 2. Ambil transaksi terakhir untuk di-print (sebagai alternatif, return transaction dari createTransaction)
    final lastTransaction = await _getLastTransaction(userId);

    if (lastTransaction == null) {
      throw Exception('Gagal mengambil data transaksi');
    }

    // 3. Bersihkan keranjang
    ref.read(cartProvider.notifier).clear();

    // 4. Cek apakah auto-print aktif
    final settings = await ref.read(printerSettingsNotifierProvider.future);
    
    if (mounted) {
      // 5. Tampilkan dialog sukses dengan opsi print
      final shouldPrint = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Transaksi Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No: ${lastTransaction.transactionNumber}'),
              Text('Total: ${Formatters.currency.format(lastTransaction.totalAmount)}'),
              const SizedBox(height: 16),
              if (settings.printerIp != null)
                const Text('Cetak struk sekarang?')
              else
                const Text(
                  'Printer belum dikonfigurasi.\nAtur di menu Pengaturan.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Tidak'),
            ),
            if (settings.printerIp != null)
              ElevatedButton.icon(
  icon: const Icon(Icons.print),
  label: const Text('Cetak'),
  onPressed: () => Navigator.of(ctx).pop(true),
),
          ],
        ),
      );

      // 6. Print jika user memilih atau auto-print aktif
      if (shouldPrint == true || settings.autoPrint) {
        if (settings.printerIp != null) {
          await _printReceipt(lastTransaction, settings);
        }
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan transaksi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Fungsi helper untuk mengambil transaksi terakhir
Future<Transaction?> _getLastTransaction(String userId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    return Transaction.fromFirestore(snapshot.docs.first);
  } catch (e) {
    print('Error getting last transaction: $e');
    return null;
  }
}

// Fungsi helper untuk print
Future<void> _printReceipt(Transaction transaction, PrinterSettings settings) async {
  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final user = ref.read(currentUserProvider).value;
  final service = ref.read(printerServiceProvider);

  final success = await service.printReceipt(
    printerIp: settings.printerIp!,
    transaction: transaction,
    shopName: user?.shopName ?? 'KasKredit',
    footerNote: settings.footerNote,
  );

  // Close loading
  if (mounted) Navigator.of(context).pop();

  // Show result
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Struk berhasil dicetak' : 'Gagal mencetak struk'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
  Widget _InfoRow({required String label, required String value, bool isBold = false}) {
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