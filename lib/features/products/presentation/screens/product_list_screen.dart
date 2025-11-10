import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_providers.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';

// 1. Ubah dari StatelessWidget menjadi ConsumerWidget
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  // 2. Tambahkan 'WidgetRef ref'
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. "Tonton" provider products
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Produk"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nanti kita buat halaman AddProduct
          context.go('/products/add');
        },
        child: const Icon(Icons.add),
      ),
      // 4. Gunakan .when() untuk handle state (loading, error, data)
      body: productsAsync.when(
        // === State Sukses (Data Diterima) ===
        data: (products) {
          // Sesuai blueprint: Tampilkan empty state jika produk kosong
          if (products.isEmpty) {
            return const Center(
              child: Text("Belum ada produk. Tekan tombol + untuk menambah."),
            );
          }

          // Sesuai blueprint: Tampilkan ListView
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    "Stok: ${product.stock} | Harga: ${Formatters.currency.format(product.sellingPrice)}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.push('/products/edit/${product.id}');
                  },
                ),
              );
            },
          );
        },
        // === State Error ===
        error: (err, stack) => Center(
          child: Text("Error memuat produk: $err"),
        ),
        // === State Loading ===
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}