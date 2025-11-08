import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/products/data/product_repository.dart';
import 'package:kaskredit_1/shared/models/product.dart';

// 1. GANTI NAMA CLASS
class EditProductScreen extends ConsumerStatefulWidget {
  // 2. TAMBAHKAN product YANG MAU DIEDIT
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  // 3. GANTI NAMA STATE
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

// 4. GANTI NAMA STATE
class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _capitalPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();

  // 5. TAMBAHKAN initState UNTUK MENGISI FORM
  @override
  void initState() {
    super.initState();
    // Isi controller dengan data produk yang ada
    _nameController.text = widget.product.name;
    _capitalPriceController.text = widget.product.capitalPrice.toStringAsFixed(0);
    _sellingPriceController.text = widget.product.sellingPrice.toStringAsFixed(0);
    _stockController.text = widget.product.stock.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capitalPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // 6. UBAH FUNGSI _submit MENJADI _update
  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // (Kita tidak perlu cek User ID lagi, karena produk sudah ada)

    setState(() { _isLoading = true; });

    try {
      // Buat objek produk yang sudah diupdate
      // Kita pakai .copyWith() dari produk yang ada
      final updatedProduct = widget.product.copyWith(
        name: _nameController.text,
        capitalPrice: double.tryParse(_capitalPriceController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        updatedAt: DateTime.now(), // Perbarui tanggal update
      );

      // Panggil repository untuk UPDATE
      await ref.read(productRepositoryProvider).updateProduct(updatedProduct);

      if (mounted) {
        context.pop(); // Kembali ke halaman list produk
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengupdate produk: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _delete() async {
    // 1. Tampilkan dialog konfirmasi
    final bool? confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Anda yakin ingin menghapus produk '${widget.product.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // Batal
            child: const Text("Batal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true), // Ya, Hapus
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    // 2. Jika user tidak konfirmasi, jangan lakukan apa-apa
    if (confirmed == null || !confirmed) {
      return;
    }

    // 3. Jika dikonfirmasi, panggil repository
    setState(() { _isLoading = true; });

    try {
      // Panggil soft delete
      await ref.read(productRepositoryProvider).deleteProduct(widget.product.id!);
      
      if (mounted) {
        // Kembali ke halaman list
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus produk: $e")),
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
        title: const Text("Edit Produk"),
        actions: [
          // Tombol Simpan
          if (!_isLoading) ...[
            // Tombol Simpan
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _update,
            ),
            // TOMBOL HAPUS BARU
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red, // Beri warna merah
              onPressed: _delete,
            ),
          ] else
            // Tampilkan loading di AppBar
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
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