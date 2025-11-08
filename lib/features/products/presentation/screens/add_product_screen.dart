import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/products/data/product_repository.dart';
import 'package:kaskredit_1/shared/models/product.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller untuk setiap field
  final _nameController = TextEditingController();
  final _capitalPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _capitalPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Dapatkan user ID
    final userId = ref.read(currentUserProvider).value?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User tidak ditemukan.")),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 3. Buat objek Product baru
      final newProduct = Product(
        userId: userId,
        name: _nameController.text,
        capitalPrice: double.tryParse(_capitalPriceController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 4. Panggil repository untuk menyimpan ke Firestore
      await ref.read(productRepositoryProvider).addProduct(newProduct);

      // 5. Kembali ke halaman list produk
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan produk: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Produk Baru"),
        actions: [
          // Tombol Simpan
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _submit,
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Nama Produk
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Produk",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? "Nama produk tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            // Harga Modal
            TextFormField(
              controller: _capitalPriceController,
              decoration: const InputDecoration(
                labelText: "Harga Modal",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Harga modal tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            // Harga Jual
            TextFormField(
              controller: _sellingPriceController,
              decoration: const InputDecoration(
                labelText: "Harga Jual",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Harga jual tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            // Stok
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: "Jumlah Stok Awal",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Stok tidak boleh kosong"
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}